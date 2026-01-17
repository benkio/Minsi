module Model.State.StateFromHtml where

import Effect.Exception (error)
import Web.HTML.HTMLInputElement (HTMLInputElement, value, valueAsNumber, checked)
import Effect (Effect)
import Data.Traversable (traverse)

import Components.HtmlComponents (HtmlComponents(..))
import Model.State.State (State(..), DurationRange(..))
import Node.URL (URL)
import Prelude
import Data.Time.Duration (Milliseconds(..))
import Node.URL (new)
import Data.Validation.Semigroup (V, invalid)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Control.Monad.Error.Class (liftEither)
import Data.Bifunctor (lmap)

fromHtmlComponents :: HtmlComponents -> Effect (V (Array String) State)
fromHtmlComponents (HtmlComponents { cutStart, cutEnd, youtubeUrl: youtubeUrlInput, filename: filenameInput, reverseLoop: reverseLoopInput, artist: artistInput, title: titleInput }) = do
  cutVideoV <- cutVideoFromHtmlRange cutStart cutEnd
  youtubeUrlV <- youtubeUrlFromHTMLInput youtubeUrlInput
  filenameValue <- value filenameInput
  reverseLoopValue <- checked reverseLoopInput
  artistValue <- value artistInput
  titleValue <- value titleInput
  pure $ ado
    cutVideo <- cutVideoV
    youtubeUrl <- youtubeUrlV
    in State { cutVideo: cutVideo, youtubeUrl: youtubeUrl, filename: filenameValue, reverseLoop: reverseLoopValue, artist: artistValue, title: titleValue, subtitles: [] }

cutVideoFromHtmlRange :: HTMLInputElement -> HTMLInputElement -> Effect (V (Array String) DurationRange)
cutVideoFromHtmlRange cutStart cutEnd = do
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  pure $ cutVideoValidation start end

cutVideoValidation :: Number -> Number -> V (Array String) DurationRange
cutVideoValidation start end =
  if start > end then invalid [ "start > end: " <> show start <> " " <> show end ]
  else pure $ DurationRange { start: Milliseconds start, end: Milliseconds end }

youtubeRegexString :: String
youtubeRegexString = """(http:|https:)?(\/\/)?(www\.)?(youtube.com|youtu.be)\/(watch|embed)?(\?v=|\/)?(\S+)?"""

youtubeUrlFromHTMLInput :: HTMLInputElement -> Effect (V (Array String) URL)
youtubeUrlFromHTMLInput youtubeUrlComponent = value youtubeUrlComponent >>= youtubeUrlValidation

youtubeUrlValidation :: String -> Effect (V (Array String) URL)
youtubeUrlValidation v = do
  youtubeRegex <- liftEither $ lmap error (regex youtubeRegexString noFlags)
  traverse new (matches youtubeRegex v)

matches :: Regex -> String -> V (Array String) String
matches r v | test r v = pure v
matches r v = invalid [ "Youtube Input does not matches the requested format, value: " <> v <> " regex: " <> show r ]
