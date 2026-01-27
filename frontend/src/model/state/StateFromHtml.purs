module Model.State.StateFromHtml where

import Data.Array (catMaybes, fromFoldable, head)
import Data.Int (round)
import Data.Map (Map)
import Data.Maybe (Maybe(..), maybe)
import Data.Traversable (traverse)
import Data.Time.Duration (Milliseconds(..))
import Web.DOM.Element (fromNode, toParentNode, toNode)
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML.HTMLInputElement (HTMLInputElement, value, valueAsNumber, checked)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HTR
import Web.HTML.HTMLTableSectionElement as HTS
import Web.HTML.HTMLTextAreaElement as HTA
import Web.HTML.HTMLTableCellElement as HTC
import Effect (Effect)
import Components.HtmlComponents (HtmlInputs(..), HtmlOutputs(..))
import Model.State.State (State(..), DurationRange(..), WURL(..), Subtitle(..), Font(..), Color(..), Position(..))
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

loadSubtitlesFromTable :: HT.HTMLTableElement -> Effect (Array Subtitle)
loadSubtitlesFromTable table = do
  tbodyMaybe <- HT.tBodies table >>= \bodies -> pure $ head (fromFoldable bodies)
  case tbodyMaybe of
    Nothing -> pure []
    Just tbody -> do
      rows <- HTS.rows tbody
      rowArray <- fromFoldable rows
      subtitles <- catMaybes <$> traverse loadSubtitleFromRow rowArray
      pure subtitles

loadSubtitleFromRow :: HTR.HTMLTableRowElement -> Effect (Maybe Subtitle)
loadSubtitleFromRow row = do
  cells <- HTR.cells row
  let cellArray = fromFoldable cells
  case cellArray of
    [startCell, endCell, valueCell, fontCell, fontSizeCell, colorCell, positionCell, _] -> do
      startValue <- getInputValueFromCell startCell >>= \v -> pure $ maybe 0.0 identity v
      endValue <- getInputValueFromCell endCell >>= \v -> pure $ maybe 0.0 identity v
      valueText <- getTextAreaValueFromCell valueCell
      fontValue <- getSelectValueFromCell fontCell
      fontSizeValue <- getInputValueFromCell fontSizeCell >>= \v -> pure $ maybe 48 (round <<< identity) v
      colorValue <- getSelectValueFromCell colorCell
      positionValue <- getSelectValueFromCell positionCell
      pure $ Just $ Subtitle
        { videoPosition: DurationRange
            { start: Milliseconds (startValue * 1000.0)
            , end: Milliseconds (endValue * 1000.0)
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

parseFont :: String -> Font
parseFont "Arial Black" = ArialBlack
parseFont _ = Impact

parseColor :: String -> Color
parseColor "Black" = Black
parseColor "Light Green" = LightGreen
parseColor "Light Orange" = LightOrange
parseColor "Yellow" = Yellow
parseColor _ = White

parsePosition :: String -> Position
parsePosition "Top" = Top
parsePosition _ = Bottom
