module Controller.ComputeController where

import Prelude

import Command.Ffmpeg (extractMp3)
import Command.Id3v2 (addId3Tags)
import Command.Ytdlp (downloadVideo)
import Data.Foldable (sum)
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
compute (State { youtubeUrl, filename, cutVideo: (DurationRange { start: start, end: end }), artist, title }) store = do
  --TODO: check if a previous execution exists for the filename
  -- yes -> kill it
  -- then -> delete all remaining files
  insert filename Pending store
  log "Starting video download in background..."
  launchAff_ $ catchError
    ( do
        cutResult <- downloadVideo youtubeUrl filename start end
        mp3result <- extractMp3 filename
        id3result <- addId3Tags filename artist title
        let
          totalExitCode = (sum <<< map exitToInt)
            [ cutResult.exit
            , mp3result.exit
            , id3result.exit -- , gifResult.exit
            ]
          processResult = if totalExitCode == 0 then Succeed else Failed
        liftEffect $ insert filename processResult store
    )
    (\_ -> liftEffect $ insert filename Failed store)
  log "Video download launched, returning HTTP response"

exitToInt :: Exit -> Int
exitToInt (Normally 0) = 0
exitToInt _ = 1
