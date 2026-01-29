module Controller.ComputeController where

import Prelude

import Command.Ffmpeg (extractMp3)
import Command.Id3v2 (addId3Tags)
import Command.Ytdlp (downloadVideo)
import Control.Monad.Error.Class (catchError)
import Control.Monad.Except (runExcept)
import Data.Array (fromFoldable)
import Data.Bifunctor (lmap)
import Data.Either (Either(Left, Right))
import Data.Foldable (sum)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store, insert, lookup)
import Model.ProcessStatus (ProcessStatus(..), isFinished)
import Model.State (State(..), DurationRange(..), validateState)
import Node.ChildProcess.Types (Exit(..))
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (sendJson, setStatus, end)

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
    _ -> pure (Success state)

compute :: State -> Store -> Effect Unit
compute (State { youtubeUrl, filename, cutVideo: (DurationRange { start: start, end: end }), artist, title }) store = do
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
