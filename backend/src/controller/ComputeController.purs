module Controller.ComputeController where

import Prelude

import Api.HttpLog (respondEmptyPost, respondJsonPost)
import Command.ExecaHelpers (exceptTMultiple, exceptTStep)
import Command.Ffmpeg.AudioNormalization (normalizeAudio)
import Command.Ffmpeg.Gif (makeGif)
import Command.Ffmpeg.Loop (applyReverseLoop)
import Command.Ffmpeg.LoopbackSpeed (applyLoopbackSpeed)
import Command.Ffmpeg.Mp3 (extractMp3)
import Command.Ffmpeg.Video (FfmpegInput(..), cutVideo)
import Command.Id3v2 (addId3Tags)
import Command.Ytdlp (YtdlpDownloadResult(..), YtdlpInput(..), ytdlpDownload)
import Constants (uploaded)
import Control.Monad.Except (runExceptT)
import Data.Array (fromFoldable)
import Data.Bifunctor (lmap)
import Data.Either (Either, either)
import Data.Maybe (Maybe(..), maybe)
import Domain.ProcessStatus (ProcessStatus(..), isFinished)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store, insert, insertProcessStatus, lookupProcessStatus)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (DurationRange(..), Source(..), State(..), WURL(..), validateState)
import Node.Library.Execa (ExecaResult)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody')
import Yoga.JSON (read)

data ComputeResponse
  = InvalidInput (Array String)
  | PendingComputation
  | Success (Maybe State) State

computeController :: Store -> Handler
computeController store = do
  bodyForeign <- getBody'
  let stateParsingResult = validateState =<< lmap (fromFoldable <<< map show) (read bodyForeign)
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
  insert filename (Just state) (Pending "Starting Computing") store
  log "Starting video download in background..."
  launchAff_ $ do
    result <- runComputePipeline mayOldState state store
    liftEffect $ saveComputeResult result
  log "Video download launched, returning HTTP response"
  where
  saveComputeResult result = do
    processResult <- either
      (\e -> log ("error during compute: " <> e) *> pure (Failed e))
      (\_ -> pure Succeed)
      result
    insert filename (Just state) processResult store

runComputePipeline :: Maybe State -> State -> Store -> Aff (Either String Unit)
runComputePipeline mayOldState state@(State { source, filename, cutVideo: range, artist, title, shiftVideoSync, loopbackSpeed }) store =
  runExceptT do
    liftEffect $ log ("[Compute] Start pipeline for filename: " <> filename)
    when (cutDownloadRequired mayOldState state)
      $ void
      $ exceptTStep "Video Download / Extraction"
      $ liftEffect (insertProcessStatus filename (Pending "Video Download / Extraction") store)
          *> videoDownloadExtraction source filename range

    when (audioNormalizationRequired mayOldState state)
      $ void
      $ exceptTStep "Audio Normalization"
      $ liftEffect (insertProcessStatus filename (Pending "Audio Normalization") store)
          *> normalizeAudio filename shiftVideoSync

    when (loopbackSpeedRequired mayOldState state)
      $ void
      $ exceptTStep "Loopback Speed"
      $ liftEffect (insertProcessStatus filename (Pending "Loopback Speed") store)
          *> applyLoopbackSpeed filename loopbackSpeed

    when (loopRequired mayOldState state)
      $ void
      $ exceptTStep "Loop"
      $ liftEffect (insertProcessStatus filename (Pending "Loop") store)
          *> applyReverseLoop filename

    liftEffect $ log ("[Compute] Extract MP3 for filename: " <> filename)
    liftEffect $ insertProcessStatus filename (Pending "MP3 extraction") store
    void $ exceptTStep "MP3 extraction" $ extractMp3 filename

    liftEffect $ insertProcessStatus filename (Pending "ID3 tags") store
    void $ exceptTStep "ID3 tags" $ addId3Tags filename artist title

    liftEffect $ insertProcessStatus filename (Pending "Gif Creation") store
    void $ exceptTMultiple "Gif Creation" $ makeGif state

    liftEffect $ log ("[Compute] Pipeline completed for filename: " <> filename)
    pure unit

videoDownloadExtraction :: Source -> String -> DurationRange -> Aff ExecaResult
videoDownloadExtraction (WebURL (WURL url)) filename (DurationRange { start, end }) = do
  result <- ytdlpDownload (YtdlpInput { url, filename, maybeStart: Just start, maybeEnd: Just end, streaming: false })
  case result of
    YtdlpDownloadResult execaResult -> pure execaResult
    YtdlpDownloadProcess _ -> liftEffect $ throwMinsiError (YtdlpError "Streaming download is not implemented yet")
videoDownloadExtraction (LocalFile _) filename (DurationRange { start, end }) = do
  fn <- liftEffect $ uploaded filename
  cutVideo (FfmpegInput { input: fn, filename, maybeStart: Just start, maybeEnd: Just end })

cutDownloadRequired :: Maybe State -> State -> Boolean
cutDownloadRequired mayOldState newState@(State { source: newSource, cutVideo: newCutVideo }) =
  maybe true
    ( \(State { source: oldSource, cutVideo: oldCutVideo }) ->
        oldSource /= newSource
          || oldCutVideo /= newCutVideo
          || shiftVideoSyncChanged mayOldState newState
          || reverseLoopChanged mayOldState newState
    )
    mayOldState

videoNormalizationRequired :: Maybe State -> State -> Boolean
videoNormalizationRequired mayOldState newState =
  cutDownloadRequired mayOldState newState || shiftVideoSyncChanged mayOldState newState || reverseLoopChanged mayOldState newState || loopbackSpeedChanged mayOldState newState

audioNormalizationRequired :: Maybe State -> State -> Boolean
audioNormalizationRequired = videoNormalizationRequired

loopbackSpeedRequired :: Maybe State -> State -> Boolean
loopbackSpeedRequired mayOldState newState@(State { loopbackSpeed }) =
  videoNormalizationRequired mayOldState newState && loopbackSpeed /= 1.0

loopRequired :: Maybe State -> State -> Boolean
loopRequired mayOldState newState@(State { reverseLoop }) =
  videoNormalizationRequired mayOldState newState && reverseLoop

shiftVideoSyncChanged :: Maybe State -> State -> Boolean
shiftVideoSyncChanged mayOldState (State { shiftVideoSync: newShift }) =
  maybe false (\(State { shiftVideoSync: oldShift }) -> oldShift /= newShift) mayOldState

reverseLoopChanged :: Maybe State -> State -> Boolean
reverseLoopChanged mayOldState (State { reverseLoop: newReverseLoop }) =
  maybe false (\(State { reverseLoop: oldReverseLoop }) -> oldReverseLoop /= newReverseLoop) mayOldState

loopbackSpeedChanged :: Maybe State -> State -> Boolean
loopbackSpeedChanged mayOldState (State { loopbackSpeed: newLoopbackSpeed }) =
  maybe false (\(State { loopbackSpeed: oldLoopbackSpeed }) -> oldLoopbackSpeed /= newLoopbackSpeed) mayOldState
