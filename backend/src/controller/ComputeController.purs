module Controller.ComputeController where

--import Ffmpeg (downloadVideo)

import Command.Ytdlp (downloadVideo)

import Effect (Effect)
import Prelude
import Effect.Class (liftEffect)
import Effect.Console (log)
import Data.Either (Either(Left, Right))
import Control.Monad.Except (runExcept)
import Model.State (State(..), DurationRange(..))
import Node.Express.Request (getBody)
import Node.Express.Handler (Handler)
import Node.Express.Response (sendJson, setStatus, end)

computeController :: Handler
computeController = do
  stateParsingResult <- getBody
  case runExcept stateParsingResult of
    Left errors -> do
      liftEffect $ log ("Failed to parse state: " <> show errors)
      setStatus 400 *> sendJson { error: "Bad Request: Failed to parse state" } *> end
    Right state -> liftEffect (compute state) *> setStatus 200 *> end

compute :: State -> Effect Unit
compute (State { youtubeUrl,filename, cutVideo: (DurationRange {start:start, end:end}) }) = do
  --TODO: check if a previous execution exists for the filename
  -- yes -> kill it
  -- then -> delete all remaining files
  downloadVideo youtubeUrl filename start end
  --log urlString
  --downloadVideo urlString filename start end
  log "endDownloadVideo"
