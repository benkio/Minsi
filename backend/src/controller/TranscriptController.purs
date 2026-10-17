module Controller.TranscriptController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Constants (md)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (message, try)
import InMemoryDB (Store)
import Node.Encoding (Encoding(..))
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.FS.Sync (exists, readTextFile)

data TranscriptReadError
  = InvalidTranscriptIdentifier
  | TranscriptFileNotFound
  | TranscriptReadFailure String

transcriptController :: Store -> Handler
transcriptController _store = do
  bodyResult <- getBody
  either badRequest handleTranscriptRequest (runExcept bodyResult)

handleTranscriptRequest :: { filename :: String } -> Handler
handleTranscriptRequest { filename } = do
  contentResult <- liftEffect $ readTranscriptMarkdown filename
  case contentResult of
    Left InvalidTranscriptIdentifier -> do
      liftEffect $ log "[Transcript Controller] Invalid transcript filename."
      respondJsonPost "/transcript" 400 { error: "Bad Request: invalid filename." }
    Left TranscriptFileNotFound ->
      respondJsonPost "/transcript" 404 { error: "Transcript markdown file not found." }
    Left (TranscriptReadFailure details) -> do
      liftEffect $ log ("[Transcript Controller] Read failed: " <> details)
      respondJsonPost "/transcript" 500 { error: "Failed to read transcript markdown file." }
    Right markdown ->
      respondJsonPost "/transcript" 200 { markdown }

badRequest :: forall a. Show a => a -> Handler
badRequest errors = do
  liftEffect $ log ("[Transcript Controller] Failed to parse request body: " <> show errors)
  respondJsonPost "/transcript" 400 { error: "Bad Request." }

readTranscriptMarkdown :: String -> Effect (Either TranscriptReadError String)
readTranscriptMarkdown filename
  | not (isValidTranscriptFilename filename) = pure (Left InvalidTranscriptIdentifier)
  | otherwise = do
      filepath <- md filename
      transcriptExists <- exists filepath
      if not transcriptExists then pure (Left TranscriptFileNotFound)
      else do
        readResult <- try (readTextFile UTF8 filepath)
        pure $ either (Left <<< TranscriptReadFailure <<< message) Right readResult

isValidTranscriptFilename :: String -> Boolean
isValidTranscriptFilename filename =
  case regex """^[a-z]{1,5}_[0-9]*[A-Z][a-zA-Z0-9]*$""" noFlags of
    Left _ -> false
    Right r -> test r filename
