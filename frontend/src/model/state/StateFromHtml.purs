module Model.State.StateFromHtml where

import Data.Map (Map)
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
import Components.HtmlIds (youtubeUrlId, outputFilenameId, artistId, titleId, cutStartId)

fromHtmlInputs :: HtmlInputs -> Effect (V (Map String String) State)
fromHtmlInputs
  ( HtmlInputs
      { cutStart
      , cutEnd
      , youtubeUrl: youtubeUrlInput
      , filename: filenameInput
      , reverseLoop: reverseLoopInput
      , artist: artistInput
      , title: titleInput
      }
  ) = do
  cutVideoV <- cutVideoFromHtmlRange cutStart cutEnd
  youtubeUrlV <- youtubeUrlFromHTMLInput youtubeUrlInput
  filenameV <- nonEmptyFromHtmlInput filenameInput outputFilenameId
  reverseLoopValue <- checked reverseLoopInput
  artistV <- nonEmptyFromHtmlInput artistInput artistId
  titleV <- nonEmptyFromHtmlInput titleInput titleId
  pure $ ado
    cutVideo <- cutVideoV
    youtubeUrl <- youtubeUrlV
    filename <- filenameV
    artist <- artistV
    title <- titleV
    in
      State
        { cutVideo: cutVideo
        , youtubeUrl: WURL youtubeUrl
        , filename: filename
        , reverseLoop: reverseLoopValue
        , artist: artist
        , title: title
        , subtitles: []
        }

cutVideoFromHtmlRange :: HTMLInputElement -> HTMLInputElement -> Effect (V (Map String String) DurationRange)
cutVideoFromHtmlRange cutStart cutEnd = do
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  pure $ cutVideoValidation cutStartId (start * 1000.0) (end * 1000.0)

youtubeUrlFromHTMLInput :: HTMLInputElement -> Effect (V (Map String String) URL)
youtubeUrlFromHTMLInput youtubeUrlComponent = do
  urlString <- value youtubeUrlComponent
  pure $ youtubeUrlValidation youtubeUrlId urlString

nonEmptyFromHtmlInput :: HTMLInputElement -> String -> Effect (V (Map String String) String)
nonEmptyFromHtmlInput i id =
  value i <#> nonEmptyValidation id
