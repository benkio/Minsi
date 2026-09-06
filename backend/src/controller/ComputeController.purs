module Controller.ComputeController where

import Prelude

import Api.HttpLog (respondEmptyPost, respondJsonPost)
import Command.ExecaHelpers (exceptTMultiple, exceptTStep)
import Command.Ffmpeg.Gif (makeGif)
import Command.Ffmpeg.Mp3 (extractMp3)
import Command.Ffmpeg.Video (FfmpegInput(..), cutVideo, normalizeVideo)
import Command.Id3v2 (addId3Tags)
import Command.OpenAIWhisper (generateJson)
import Command.Ytdlp (YtdlpDownloadResult(..), YtdlpInput(..), ytdlpDownload)
import Constants (mp3, uploaded, whisperJson)
import Control.Monad.Except (lift, runExceptT)
import Data.Array (fromFoldable)
import Data.Bifunctor (lmap)
import Data.Either (Either, either)
import Data.Maybe (Maybe(..), maybe)
import Domain.ProcessStatus (ProcessStatus(..), isFinished)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (catchException)
import InMemoryDB (Store, insert, lookupProcessStatus)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (DurationRange(..), Source(..), State(..), WURL(..), validateState)
import Node.Express.Handler (Handler)
import Node.FS.Sync (exists, rm)
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
runComputePipeline mayOldState state@(State { source, filename, cutVideo: DurationRange { start, end }, artist, title, shiftVideoSync }) =
  runExceptT do
    liftEffect $ log ("[Compute] Start pipeline for filename: " <> filename)
    whisperJsonPath <- liftEffect $ whisperJson filename
    whisperJsonExists <- liftEffect $ exists whisperJsonPath
    liftEffect $ log ("[Compute] Whisper json exists at pipeline start: " <> show whisperJsonExists <> " (" <> whisperJsonPath <> ")")
    mp3Path <- liftEffect $ mp3 filename
    mp3Exists <- liftEffect $ exists mp3Path
    liftEffect $ log ("[Compute] MP3 exists at pipeline start: " <> show mp3Exists <> " (" <> mp3Path <> ")")
    when (cutDownloadRequired mayOldState state)
      ( do
          case source of
            (WebURL (WURL url)) -> do
              void $ exceptTStep "Video download" do
                result <- ytdlpDownload (YtdlpInput { url, filename, maybeStart: Just start, maybeEnd: Just end, streaming: false })
                case result of
                  YtdlpDownloadResult execaResult -> pure execaResult
                  YtdlpDownloadProcess _ -> liftEffect $ throwMinsiError (YtdlpError "Streaming download is not implemented yet")
            LocalFile _ -> void $ exceptTStep "Video download" $ (liftEffect $ uploaded filename) >>= \fn -> cutVideo (FfmpegInput { input: fn, filename, maybeStart: Just start, maybeEnd: Just end })
      )
    when (videoNormalizationRequired mayOldState state)
      $ void
      $ exceptTStep "Video Normalization"
      $ normalizeVideo filename shiftVideoSync
    liftEffect $ log ("[Compute] Extract MP3 for filename: " <> filename)
    void $ exceptTStep "MP3 extraction" $ extractMp3 filename
    if whisperRegenerationRequired mp3Exists whisperJsonExists then do
      when whisperJsonExists do
        liftEffect $ log ("[Compute] Delete previous whisper json before regeneration: " <> whisperJsonPath)
        liftEffect $ catchException (\_ -> pure unit) (rm whisperJsonPath)
      liftEffect $ log ("[Compute] Run Whisper subtitle generation (model=small) for filename: " <> filename)
      whisperResult <- lift $ runExceptT (exceptTStep "Whisper subtitle generation" $ generateJson filename)
      liftEffect $
        either
          ( \whisperErr ->
              log
                ( "[Compute] Whisper subtitle generation failed but compute will continue: "
                    <> whisperErr
                )
          )
          (\_ -> log ("[Compute] Whisper subtitle generation completed for filename: " <> filename))
          whisperResult
    else
      liftEffect $ log "[Compute] Skip Whisper subtitle generation because both MP3 and whisper json already exist at pipeline start"
    void $ exceptTStep "ID3 tags" $ addId3Tags filename artist title
    void $ exceptTMultiple "Gif Creation" $ makeGif state
    liftEffect $ log ("[Compute] Pipeline completed for filename: " <> filename)
    pure unit

cutDownloadRequired :: Maybe State -> State -> Boolean
cutDownloadRequired mayOldState newState@(State { source: newSource, cutVideo: newCutVideo }) =
  maybe true
    ( \(State { source: oldSource, cutVideo: oldCutVideo }) ->
        oldSource /= newSource || oldCutVideo /= newCutVideo || shiftVideoSyncChanged mayOldState newState
    )
    mayOldState

videoNormalizationRequired :: Maybe State -> State -> Boolean
videoNormalizationRequired mayOldState newState =
  cutDownloadRequired mayOldState newState || shiftVideoSyncChanged mayOldState newState

shiftVideoSyncChanged :: Maybe State -> State -> Boolean
shiftVideoSyncChanged mayOldState (State { shiftVideoSync: newShift }) =
  maybe false (\(State { shiftVideoSync: oldShift }) -> oldShift /= newShift) mayOldState

whisperRegenerationRequired :: Boolean -> Boolean -> Boolean
whisperRegenerationRequired mp3Exists whisperJsonExists =
  not mp3Exists || not whisperJsonExists
