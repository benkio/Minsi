module Controller.SubtitlesController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Constants (whisperJson)
import Contracts.Api (WhisperSubtitlesResponse)
import Data.Array (head, last, null, snoc)
import Data.Array as Array
import Data.Either (Either, either)
import Data.Foldable (foldl)
import Data.Maybe (fromMaybe)
import Data.String (joinWith, length)
import Data.String.Common (trim)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (Color(..), DurationRange(..), Font(..), Position(..), Subtitle(..))
import Model.State.SubtitleConstraints (maxSubtitleCharsPerLine)
import Node.Encoding (Encoding(..))
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.FS.Sync (exists, readTextFile)
import Yoga.JSON (readJSON)
import Control.Monad.Except (runExcept)

type WhisperWord =
  { word :: String
  , start :: Number
  , end :: Number
  }

type WhisperSegment =
  { start :: Number
  , end :: Number
  , text :: String
  , words :: Array WhisperWord
  }

type WhisperJsonResponse = { segments :: Array WhisperSegment }

subtitlesController :: Store -> Handler
subtitlesController _store = do
  bodyResult <- getBody
  either badRequest handleSubtitlesRequest (runExcept bodyResult)

badRequest :: forall a. Show a => a -> Handler
badRequest errors = do
  liftEffect $ log ("Failed to parse request body: " <> show errors)
  respondJsonPost "/subtitles" 400 { error: "Bad Request" }

handleSubtitlesRequest :: { filename :: String } -> Handler
handleSubtitlesRequest { filename } = do
  response <- liftEffect $ loadWhisperSubtitles filename
  respondJsonPost "/subtitles" 200 response

loadWhisperSubtitles :: String -> Effect WhisperSubtitlesResponse
loadWhisperSubtitles filename = do
  filePath <- whisperJson filename
  log ("[Subtitles] Looking for whisper json at: " <> filePath)
  fileExists <- exists filePath
  log ("[Subtitles] Whisper json exists: " <> show fileExists)
  if not fileExists then
    log ("[Subtitles] No whisper json found for filename: " <> filename) *> pure { subtitles: [] }
  else do
    fileContent <- readTextFile UTF8 filePath
    let decoded = readJSON fileContent :: Either _ WhisperJsonResponse
    response <- either
      (\err -> throwMinsiError (InvalidInputError ("Could not parse whisper json: " <> show err)))
      ( \raw -> do
          let subtitleRows = linesFromSegments raw.segments
          log ("[Subtitles] Parsed whisper segments: " <> show (Array.length raw.segments))
          log ("[Subtitles] Generated subtitle rows: " <> show (Array.length subtitleRows))
          pure { subtitles: subtitleRows }
      )
      decoded
    log ("[Subtitles] Returning subtitles for filename: " <> filename)
    pure response

linesFromSegments :: Array WhisperSegment -> Array Subtitle
linesFromSegments =
  foldl (\acc seg -> acc <> linesFromSegment seg) []

linesFromSegment :: WhisperSegment -> Array Subtitle
linesFromSegment seg =
  if null seg.words then
    let
      text = trim seg.text
    in
      if text == "" then [] else [ mkSubtitle (seg.start * 1000.0) (seg.end * 1000.0) text ]
  else
    finalize acc.lines acc.currentWords
  where
  acc :: { lines :: Array Subtitle, currentWords :: Array WhisperWord }
  acc =
    foldl consumeWord { lines: [], currentWords: [] } seg.words

  consumeWord :: { lines :: Array Subtitle, currentWords :: Array WhisperWord } -> WhisperWord -> { lines :: Array Subtitle, currentWords :: Array WhisperWord }
  consumeWord localAcc word =
    let
      currentWords = localAcc.currentWords
      candidateWords = snoc currentWords word
      candidateLine = wordsToLine candidateWords
      currentLine = wordsToLine currentWords
    in
      if null currentWords || length candidateLine <= maxSubtitleCharsPerLine then
        localAcc { currentWords = candidateWords }
      else
        localAcc
          { lines = appendLine localAcc.lines currentWords currentLine
          , currentWords = [ word ]
          }

  finalize :: Array Subtitle -> Array WhisperWord -> Array Subtitle
  finalize lines currentWords =
    appendLine lines currentWords (wordsToLine currentWords)

  appendLine :: Array Subtitle -> Array WhisperWord -> String -> Array Subtitle
  appendLine lines currentWords text =
    if null currentWords || text == "" then lines
    else
      let
        start = fromMaybe seg.start ((_.start) <$> head currentWords)
        end = fromMaybe seg.end ((_.end) <$> last currentWords)
      in
        snoc lines (mkSubtitle (start * 1000.0) (end * 1000.0) text)

wordsToLine :: Array WhisperWord -> String
wordsToLine words =
  trim $ joinWith " " (trim <<< _.word <$> words)

mkSubtitle :: Number -> Number -> String -> Subtitle
mkSubtitle start end text =
  Subtitle
    { videoPosition: DurationRange
        { start: Milliseconds start
        , end: Milliseconds end
        }
    , value: text
    , font: Impact
    , fontSize: 36
    , color: White
    , screenPosition: Bottom
    }

