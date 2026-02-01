module Controller.ComputeController where

import Command.Ffmpeg.Gif (makeGif)
import Node.FS.Sync (rm)
import Data.Traversable (traverse_)
import Constants (files)
import Command.Ffmpeg.Mp3 (extractMp3)
import Command.Id3v2 (addId3Tags)
import Command.Ytdlp (downloadVideo)
import Control.Monad.Error.Class (catchError)
import Control.Monad.Except (ExceptT(..), runExcept, runExceptT, lift)
import Data.Array (fromFoldable)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (message)
import InMemoryDB (Store, insert, lookup)
import Model.ProcessStatus (ProcessStatus(..), isFinished)
import Model.State (State(..), DurationRange(..), validateState)
import Node.ChildProcess.Types (Exit(..))
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (sendJson, setStatus, end)
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)
import Prelude

data ComputeResponse =
  InvalidInput (Array String)
  | PendingComputation
  | Success State

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
    Success state ->
      liftEffect (compute state store) *> setStatus 200 *> end

computeResponse :: Store -> Either (Array String) State -> Effect ComputeResponse
computeResponse _ (Left errors) = pure (InvalidInput errors)
computeResponse store (Right state@(State { filename })) = do
  m <- lookup filename store
  case m of
    Just p | not (isFinished p) -> pure PendingComputation
    _ -> deleteFiles filename *> pure (Success state)

compute :: State -> Store -> Effect Unit
compute state@(State { filename }) store = do
  insert filename Pending store
  log "Starting video download in background..."
  launchAff_ $ do
    result <- runComputePipeline state
    processResult <- case result of
      Right _ -> pure Succeed
      Left _ -> pure Failed
    liftEffect $ insert filename processResult store
  log "Video download launched, returning HTTP response"

runComputePipeline :: State -> Aff (Either String Unit)
runComputePipeline state@(State { youtubeUrl, filename, cutVideo: DurationRange { start, end }, artist, title }) =
  runExceptT do
    void $ exceptTStep "Video download" $ downloadVideo youtubeUrl filename start end
    void $ exceptTStep "MP3 extraction" $ extractMp3 filename
    void $ exceptTStep "ID3 tags" $ addId3Tags filename artist title
    void $ exceptTMultiple "Gif Creation" $ makeGif state
    pure unit

exceptTMultiple :: String -> Aff (Array ExecaResult) -> ExceptT String Aff Unit
exceptTMultiple label affs = do
  steps <- lift affs
  traverse_ (checkExecaResult label) steps

execaResultToEither :: String -> ExecaResult -> Either String Unit
execaResultToEither label r =
  if isSuccessExit r.exit then Right unit else Left (label <> " failed")

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

deleteFiles :: FilePath -> Effect Unit
deleteFiles filename =
  files filename >>= \fs -> traverse_ (\f -> catchError (rm f) (\_ -> pure unit)) fs
