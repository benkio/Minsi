module Model.State.StateFromHtml where

import Conversion.String (capitalize)
import Data.Int (floor)
import Parse.Font (parseFont, parseColor, parsePosition)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Data.Array (length, (!!))
import Data.Maybe (Maybe(..), maybe, fromJust)
import Partial.Unsafe (unsafePartial)
import Data.TraversableWithIndex (traverseWithIndex)
import Data.Time.Duration (Milliseconds(..))
import Web.DOM.Element (toParentNode)
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML.HTMLInputElement (HTMLInputElement, value, valueAsNumber, checked)
import Data.String.Common (trim, toUpper)
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
import Model.State.State (State(..), DurationRange(..), WURL(..), Subtitle(..))
import Data.URL (URL)
import Prelude
import Data.Validation.Semigroup (V, validation)
import Model.ValidationErrors (ValidationErrors, toMap)
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
        , artist: capitalize artist
        , title: capitalize title
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
  subtitles <- traverseWithIndex loadSubtitleFromRow rows
  pure subtitles

loadSubtitleFromRow :: Int -> HTR.HTMLTableRowElement -> Effect Subtitle
loadSubtitleFromRow index row = do
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  if length cellArray /= 8 then throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: Unexpected number of columns" <> (show (length cellArray))))
  else do
    let
      startCell = unsafePartial fromJust (cellArray !! 0)
      endCell = unsafePartial fromJust (cellArray !! 1)
      valueCell = unsafePartial fromJust (cellArray !! 2)
      fontCell = unsafePartial fromJust (cellArray !! 3)
      fontSizeCell = unsafePartial fromJust (cellArray !! 4)
      colorCell = unsafePartial fromJust (cellArray !! 5)
      positionCell = unsafePartial fromJust (cellArray !! 6)
    startValue <- maybe (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: SubtitleTableStartCell"))) pure (HTC.fromElement startCell) >>= getInputValueFromCell >>= \v -> pure $ maybe 0.0 identity v
    endValue <- maybe (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: SubtitleTableEndCell"))) pure (HTC.fromElement endCell) >>= getInputValueFromCell >>= \v -> pure $ maybe 0.0 identity v
    valueText <- maybe (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: SubtitleTablevalueCell"))) pure (HTC.fromElement valueCell) >>= getTextAreaValueFromCell
    fontValue <- maybe (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: SubtitleTablefontCell"))) pure (HTC.fromElement fontCell) >>= getSelectValueFromCell
    fontSizeValue <- maybe (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: SubtitleTablefontSizeCell"))) pure (HTC.fromElement fontSizeCell) >>= getInputValueFromCell >>= \v -> pure $ maybe 48 floor v
    colorValue <- maybe (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: SubtitleTablecolorCell"))) pure (HTC.fromElement colorCell) >>= getSelectValueFromCell
    positionValue <- maybe (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: SubtitleTablepositionCell"))) pure (HTC.fromElement positionCell) >>= getSelectValueFromCell
    validation
      (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
      ( \_ -> pure $ Subtitle
          { videoPosition: DurationRange
              { start: Milliseconds (startValue)
              , end: Milliseconds (endValue)
              }
          , value: (toUpper <<< trim) valueText
          , font: parseFont fontValue
          , fontSize: fontSizeValue
          , color: parseColor colorValue
          , screenPosition: parsePosition positionValue
          }
      )
      (cutVideoValidation ("[Subtitle row " <> show index <> "]") startValue endValue)

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
