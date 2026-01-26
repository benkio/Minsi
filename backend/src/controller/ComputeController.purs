module Controller.ComputeController where

import Prelude

import Command.Ytdlp (downloadVideo)
import Control.Monad.Error.Class (catchError)
import Control.Monad.Except (runExcept)
import Data.Either (Either(Left, Right))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store, insert)
import Model.ProcessStatus (ProcessStatus(..))
import Model.State (State(..), DurationRange(..))
import Node.ChildProcess.Types (Exit(..))
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (sendJson, setStatus, end)

computeController :: Store -> Handler
computeController store = do
  stateParsingResult <- getBody
  case runExcept stateParsingResult of
    Left errors -> do
      liftEffect $ log ("Failed to parse state: " <> show errors)
      setStatus 400 *> sendJson { error: "Bad Request: Failed to parse state" } *> end
    Right state -> liftEffect (compute state store) *> setStatus 200 *> end

compute :: State -> Store -> Effect Unit
compute (State { youtubeUrl, filename, cutVideo: (DurationRange {start: start, end: end}) }) store = do
  --TODO: check if a previous execution exists for the filename
  -- yes -> kill it
  -- then -> delete all remaining files
  insert filename Pending store
  log "Starting video download in background..."
  launchAff_ $ catchError
    (downloadVideo youtubeUrl filename start end >>= \result ->
      liftEffect $ insert filename (exitToStatus result.exit) store)
    (\_ -> liftEffect $ insert filename Failed store)
  log "Video download launched, returning HTTP response"

exitToStatus :: Exit -> ProcessStatus
exitToStatus (Normally 0) = Succeed
exitToStatus _ = Failed
