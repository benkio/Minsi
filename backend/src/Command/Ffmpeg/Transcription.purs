module Command.Ffmpeg.Transcription where

import Prelude

import Command.Ffmpeg.TranscriptRestoration (restoreTranscriptWithFallback)
import Constants (md)
import Control.Monad.Error.Class (catchError)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (Error, message)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (Color(..), Font(..), State(..), Subtitle(..), subtitlesToString)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (writeTextFile)
import Node.Library.Execa (ExecaResult)

makeTranscription :: State -> Aff (Array ExecaResult)
makeTranscription (State { filename, subtitles }) =
  catchError
    ( do
        filepath <- liftEffect $ md filename
        let transcriptionRaw = subtitlesToString subtitles (Just subtitlesToMarkdown)
        transcriptionRestored <- restoreTranscriptWithFallback transcriptionRaw
        transcriptionMarkdownEscaped <- liftEffect $ escapeMarkdown transcriptionRestored
        liftEffect $ log $ "[Transcription] Execute Command: write file " <> show filepath
        liftEffect $ writeTextFile UTF8 filepath transcriptionMarkdownEscaped
        pure []
    )
    (\e -> liftEffect $ throwMinsiError (toTranscriptionError e))

toTranscriptionError :: Error -> MinsiError
toTranscriptionError e = TranscriptionError (transcriptionErrorDetails e)

transcriptionErrorDetails :: Error -> String
transcriptionErrorDetails e = "type=" <> show e <> "; message=" <> message e

subtitlesToMarkdown :: Array Subtitle -> String
subtitlesToMarkdown subtitles =
  joinWith " " (map subtitleToMarkdown subtitles)

applyRestorationThenEscaping :: (String -> String) -> (String -> String) -> String -> String
applyRestorationThenEscaping restore escape = escape <<< restore

foreign import escapeMarkdown :: String -> Effect String

subtitleToMarkdown :: Subtitle -> String
subtitleToMarkdown subtitle@(Subtitle { value }) =
  enphasis <> value <> enphasis
  where
  enphasis = subtitleToEnphasisChar subtitle

subtitleToEnphasisChar :: Subtitle -> String
subtitleToEnphasisChar (Subtitle { font: ArialBlack, color: Yellow }) = "_"
subtitleToEnphasisChar (Subtitle { font: ArialBlack, color: LightOrange }) = "*"
subtitleToEnphasisChar (Subtitle { font: ArialBlack, color: LightGreen }) = "`"
subtitleToEnphasisChar _ = ""
