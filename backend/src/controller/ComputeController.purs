module Controller.ComputeController where

import Prelude

import Command.Ffmpeg.Gif (makeGif)
import Command.Ffmpeg.Mp3 (extractMp3)
import Command.Ffmpeg.Video (normalizeVideo)
import Command.Id3v2 (addId3Tags)
import Command.Ytdlp (downloadOrCutVideo)
import Control.Monad.Error.Class (catchError)
import Control.Monad.Except (ExceptT(..), runExcept, runExceptT, lift)
import Data.Array (fromFoldable)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (message)
import InMemoryDB (Store, insert, lookup)
import Model.ProcessStatus (ProcessStatus(..), isFinished)
import Model.State (DurationRange(..), Source(WebURL), State(..), validateState)
import Node.ChildProcess.Types (Exit(..))
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (sendJson, setStatus, end)
import Node.Library.Execa (ExecaResult)

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
        *> setStatus 400
        *> sendJson { error: "Bad Request: Failed to parse state" }
        *> end
    PendingComputation ->
      liftEffect (log "Pending Computation")
        *> setStatus 500
        *> sendJson { error: "Pending Computation" }
        *> end
    Success mayOldState state ->
      liftEffect (compute mayOldState state store) *> setStatus 200 *> end

computeResponse :: Store -> Either (Array String) State -> Effect ComputeResponse
computeResponse _ (Left errors) = pure (InvalidInput errors)
computeResponse store (Right state@(State { filename })) = do
  m <- lookup filename store
  case m of
    Just { processStatus } | not (isFinished processStatus) -> pure PendingComputation
    Just { state: oldState } -> pure (Success (Just oldState) state)
    _ -> pure (Success Nothing state)

compute :: Maybe State -> State -> Store -> Effect Unit
compute mayOldState state@(State { filename }) store = do
  insert filename state Pending store
  log "Starting video download in background..."
  launchAff_ $ do
    result <- runComputePipeline mayOldState state
    processResult <- case result of
      Right _ -> pure Succeed
      Left e -> liftEffect (log ("error during compute: " <> e)) *> pure (Failed e)
    liftEffect $ insert filename state processResult store
  log "Video download launched, returning HTTP response"

runComputePipeline :: Maybe State -> State -> Aff (Either String Unit)
runComputePipeline mayOldState state@(State { source, filename, cutVideo: DurationRange { start, end }, artist, title }) =
  runExceptT do
    when (cutDownloadRequired mayOldState state)
      ( do
          void $ exceptTStep "Video download" $ downloadOrCutVideo source filename start end
          void $ exceptTStep "Video Normalization" $ normalizeVideo filename
      )
    void $ exceptTStep "MP3 extraction" $ extractMp3 filename
    void $ exceptTStep "ID3 tags" $ addId3Tags filename artist title
    void $ exceptTMultiple "Gif Creation" $ makeGif state
    pure unit


cutDownloadRequired :: Maybe State -> State -> Boolean
cutDownloadRequired Nothing _ = true
cutDownloadRequired (Just (State { source: oldSource, cutVideo: oldCutVideo })) (State { source: newSource, cutVideo: newCutVideo }) =
  oldSource /= newSource || oldCutVideo /= newCutVideo

exceptTMultiple :: String -> Aff (Array ExecaResult) -> ExceptT String Aff Unit
exceptTMultiple label affs = do
  steps <- lift affs
  traverse_ (checkExecaResult label) steps

execaResultToEither :: String -> ExecaResult -> Either String Unit
execaResultToEither label r =
  if isSuccessExit r.exit then Right unit else Left (label <> " failed. Command: " <> command <> " - stderr: " <> error)
  where
  error = r.stderr
  command = r.escapedCommand

checkExecaResult :: String -> ExecaResult -> ExceptT String Aff Unit
checkExecaResult label r = ExceptT $ pure $ execaResultToEither label r

exceptTStep :: String -> Aff ExecaResult -> ExceptT String Aff Unit
exceptTStep label aff =
  ExceptT $
    (aff >>= \r -> pure $ execaResultToEither label r)
      `catchError` (\e -> pure $ Left (label <> ": " <> message e))

isSuccessExit :: Exit -> Boolean
isSuccessExit (Normally 0) = true
isSuccessExit _ = false
