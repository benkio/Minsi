module Model.State.StateFromHtml where

import Web.HTML.HTMLInputElement (HTMLInputElement, value, valueAsNumber, checked)
import Effect (Effect)

import Components.HtmlComponents (HtmlInputs(..))
import Model.State.State (State(..), DurationRange, WURL(..))
import Data.URL (URL)
import Prelude
import Data.Validation.Semigroup (V)
import Validations.YoutubeValidation (youtubeUrlValidation)
import Validations.NonEmptyValidation (nonEmptyValidation)
import Validations.CutVideoValidation (cutVideoValidation)

fromHtmlInputs :: HtmlInputs -> Effect (V (Array String) State)
fromHtmlInputs (HtmlInputs { cutStart, cutEnd, youtubeUrl: youtubeUrlInput, filename: filenameInput, reverseLoop: reverseLoopInput, artist: artistInput, title: titleInput }) = do
  cutVideoV <- cutVideoFromHtmlRange cutStart cutEnd
  youtubeUrlV <- youtubeUrlFromHTMLInput youtubeUrlInput
  filenameV <- nonEmptyFromHtmlInput filenameInput
  reverseLoopValue <- checked reverseLoopInput
  artistV <- nonEmptyFromHtmlInput artistInput
  titleV <- nonEmptyFromHtmlInput titleInput
  pure $ ado
    cutVideo <- cutVideoV
    youtubeUrl <- youtubeUrlV
    filename <- filenameV
    artist <- artistV
    title <- titleV
    in State { cutVideo: cutVideo, youtubeUrl: WURL youtubeUrl, filename: filename, reverseLoop: reverseLoopValue, artist: artist, title: title, subtitles: [] }

cutVideoFromHtmlRange :: HTMLInputElement -> HTMLInputElement -> Effect (V (Array String) DurationRange)
cutVideoFromHtmlRange cutStart cutEnd = do
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  pure $ cutVideoValidation start end

youtubeUrlFromHTMLInput :: HTMLInputElement -> Effect (V (Array String) URL)
youtubeUrlFromHTMLInput youtubeUrlComponent = do
  urlString <- value youtubeUrlComponent
  pure $ youtubeUrlValidation urlString

nonEmptyFromHtmlInput :: HTMLInputElement -> Effect (V (Array String) String)
nonEmptyFromHtmlInput i =
  value i <#> nonEmptyValidation
