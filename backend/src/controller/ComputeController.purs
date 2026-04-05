module Controller.ComputeController where

import Prelude

import Api.HttpLog (respondEmptyPost, respondJsonPost)
import Command.ExecaHelpers (exceptTMultiple, exceptTStep)
import Command.Ffmpeg.Gif (makeGif)
import Command.Ffmpeg.Mp3 (extractMp3)
import Command.Ffmpeg.Video (FfmpegInput(..), cutVideo, normalizeVideo)
import Command.Id3v2 (addId3Tags)
import Command.Ytdlp (YtdlpInput(..), ytdlpDownload)
import Constants (uploaded)
import Control.Monad.Except (runExcept, runExceptT)
import Data.Array (fromFoldable)
import Data.Bifunctor (lmap)
import Data.Either (Either, either)
import Data.Maybe (Maybe(..), maybe)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store, insert, lookupProcessStatus)
import Model.ProcessStatus (ProcessStatus(..), isFinished)
import Model.State (DurationRange(..), Source(..), State(..), WURL(..), validateState)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)

data ComputeResponse
  = InvalidInput (Array String)
  | PendingComputation
  | Success (Maybe State) State

computeController :: Store -> Handler
computeController store = do
  bodyResult <- getBody
  let stateParsingResult = validateState =<< lmap (fromFoldable <<< map show) (runExcept bodyResult)
  response <- liftEffect $ computeResponse store stateParsingResult
  case response of
    InvalidInput errors ->
      liftEffect (log ("Failed to parse state: " <> show errors))
        *> respondJsonPost "/compute" 400 { error: "Bad Request: Failed to parse state" }
    PendingComputation ->
      liftEffect (log "Pending Computation")
        *> respondJsonPost "/compute" 500 { error: "Pending Computation" }
    Success mayOldState state ->
      liftEffect (compute mayOldState state store) *> respondEmptyPost "/compute" 200

computeResponse :: Store -> Either (Array String) State -> Effect ComputeResponse
computeResponse store =
  either
    (pure <<< InvalidInput)
    ( \state@(State { filename }) -> do
        m <- lookupProcessStatus filename store
        pure $ maybe
          (Success Nothing state)
          (\rec -> if not (isFinished rec.processStatus) then PendingComputation else Success rec.state state)
          m
    )

compute :: Maybe State -> State -> Store -> Effect Unit
compute mayOldState state@(State { filename }) store = do
  insert filename (Just state) Pending store
  log "Starting video download in background..."
  launchAff_ $ do
    result <- runComputePipeline mayOldState state
    liftEffect $ saveComputeResult result
  log "Video download launched, returning HTTP response"
  where
  saveComputeResult result = do
    processResult <- either
      (\e -> log ("error during compute: " <> e) *> pure (Failed e))
      (\_ -> pure Succeed)
      result
    insert filename (Just state) processResult store

runComputePipeline :: Maybe State -> State -> Aff (Either String Unit)
runComputePipeline mayOldState state@(State { source, filename, cutVideo: DurationRange { start, end }, artist, title }) =
  runExceptT do
    when (cutDownloadRequired mayOldState state)
      ( do
          case source of
            (WebURL (WURL url)) -> void $ exceptTStep "Video download" $ ytdlpDownload (YtdlpInput { url, filename, maybeStart: Just start, maybeEnd: Just end })
            LocalFile -> void $ exceptTStep "Video download" $ (liftEffect $ uploaded filename) >>= \fn -> cutVideo (FfmpegInput { input: fn, filename, maybeStart: Just start, maybeEnd: Just end })
          void $ exceptTStep "Video Normalization" $ normalizeVideo filename
      )
    void $ exceptTStep "MP3 extraction" $ extractMp3 filename
    void $ exceptTStep "ID3 tags" $ addId3Tags filename artist title
    void $ exceptTMultiple "Gif Creation" $ makeGif state
    pure unit

cutDownloadRequired :: Maybe State -> State -> Boolean
cutDownloadRequired mayOldState (State { source: newSource, cutVideo: newCutVideo }) =
  maybe true
    (\(State { source: oldSource, cutVideo: oldCutVideo }) -> oldSource /= newSource || oldCutVideo /= newCutVideo)
    mayOldState
