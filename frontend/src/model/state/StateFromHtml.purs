module Model.State.StateFromHtml where

import Data.Int (floor)

import Parse.Font (parseFont, parseColor, parsePosition)

import Main.MinsiError (MinsiError(..), throwMinsiError)
import Data.Array (catMaybes)
import Data.Int (fromString)
import Data.Maybe (Maybe(..), maybe, fromMaybe)
import Data.Traversable (traverse)
import Data.Time.Duration (Milliseconds(..))
import Web.DOM.Element (toParentNode)
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML.HTMLInputElement (HTMLInputElement, value, valueAsNumber, checked)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HTR
import Components.HTMLTableElement (getRows)
import Web.HTML.HTMLTextAreaElement as HTA
import Web.HTML.HTMLTableCellElement as HTC
import Web.DOM.HTMLCollection as HC
import Effect (Effect)
import Components.HtmlComponents (HtmlInputs(..))
import Model.State.State (State(..), DurationRange(..), WURL(..), Subtitle(..), Font(..), Color(..), Position(..))
import Data.URL (URL)
import Prelude
import Data.Validation.Semigroup (V)
import Model.ValidationErrors (ValidationErrors)
import Validations.YoutubeValidation (youtubeUrlValidation)
import Validations.NonEmptyValidation (nonEmptyValidation)
import Validations.CutVideoValidation (cutVideoValidation)
import Components.HtmlIds (youtubeUrlId, outputFilenameId, artistId, titleId, cutStartId)

fromHtmlInputs :: HtmlInputs -> Effect (V ValidationErrors State)
fromHtmlInputs
  ( HtmlInputs
      { cutStart
      , cutEnd
      , youtubeUrl: youtubeUrlInput
      , filename: filenameInput
      , reverseLoop: reverseLoopInput
      , artist: artistInput
      , title: titleInput
      , subtitleTable
      }
  ) = do
  cutVideoV <- cutVideoFromHtmlRange cutStart cutEnd
  youtubeUrlV <- youtubeUrlFromHTMLInput youtubeUrlInput
  filenameV <- nonEmptyFromHtmlInput filenameInput outputFilenameId
  reverseLoopValue <- checked reverseLoopInput
  artistV <- nonEmptyFromHtmlInput artistInput artistId
  titleV <- nonEmptyFromHtmlInput titleInput titleId
  subtitles <- loadSubtitlesFromTable subtitleTable
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
        , subtitles: subtitles
        }

cutVideoFromHtmlRange :: HTMLInputElement -> HTMLInputElement -> Effect (V ValidationErrors DurationRange)
cutVideoFromHtmlRange cutStart cutEnd = do
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  pure $ cutVideoValidation cutStartId start end

youtubeUrlFromHTMLInput :: HTMLInputElement -> Effect (V ValidationErrors URL)
youtubeUrlFromHTMLInput youtubeUrlComponent = do
  urlString <- value youtubeUrlComponent
  pure $ youtubeUrlValidation youtubeUrlId urlString

nonEmptyFromHtmlInput :: HTMLInputElement -> String -> Effect (V ValidationErrors String)
nonEmptyFromHtmlInput i id =
  value i <#> nonEmptyValidation id

loadSubtitlesFromTable :: HT.HTMLTableElement -> Effect (Array Subtitle)
loadSubtitlesFromTable table = do
  rows <- getRows table
  subtitles <- catMaybes <$> traverse loadSubtitleFromRow rows
  pure subtitles

loadSubtitleFromRow :: HTR.HTMLTableRowElement -> Effect (Maybe Subtitle)
loadSubtitleFromRow row = do
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  case cellArray of
    [startCell, endCell, valueCell, fontCell, fontSizeCell, colorCell, positionCell, _] -> do
      startValue <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableStartCell")) pure (HTC.fromElement startCell) >>= getInputValueFromCell >>= \v -> pure $ maybe 0.0 identity v
      endValue <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableEndCell")) pure (HTC.fromElement endCell) >>= getInputValueFromCell >>= \v -> pure $ maybe 0.0 identity v
      valueText <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTablevalueCell")) pure (HTC.fromElement valueCell) >>= getTextAreaValueFromCell
      fontValue <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTablefontCell")) pure (HTC.fromElement fontCell) >>= getSelectValueFromCell
      fontSizeValue <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTablefontSizeCell")) pure (HTC.fromElement fontSizeCell) >>= getInputValueFromCell >>= \v -> pure $ maybe 48 floor v
      colorValue <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTablecolorCell")) pure (HTC.fromElement colorCell) >>= getSelectValueFromCell
      positionValue <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTablepositionCell")) pure (HTC.fromElement positionCell) >>= getSelectValueFromCell
      pure $ Just $ Subtitle
        { videoPosition: DurationRange
            { start: Milliseconds (startValue)
            , end: Milliseconds (endValue)
            }
        , value: valueText
        , font: parseFont fontValue
        , fontSize: fontSizeValue
        , color: parseColor colorValue
        , screenPosition: parsePosition positionValue
        }
    _ -> pure Nothing

getInputValueFromCell :: HTC.HTMLTableCellElement -> Effect (Maybe Number)
getInputValueFromCell cell = do
  let element = HTC.toElement cell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "input") parentNode
  let inputMaybe = elementMaybe >>= HI.fromElement
  case inputMaybe of
    Nothing -> pure Nothing
    Just input -> valueAsNumber input <#> Just

getTextAreaValueFromCell :: HTC.HTMLTableCellElement -> Effect String
getTextAreaValueFromCell cell = do
  let element = HTC.toElement cell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "textarea") parentNode
  let textareaMaybe = elementMaybe >>= HTA.fromElement
  case textareaMaybe of
    Nothing -> pure ""
    Just textarea -> HTA.value textarea

getSelectValueFromCell :: HTC.HTMLTableCellElement -> Effect String
getSelectValueFromCell cell = do
  let element = HTC.toElement cell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "select") parentNode
  let selectMaybe = elementMaybe >>= HS.fromElement
  case selectMaybe of
    Nothing -> pure ""
    Just select -> HS.value select
