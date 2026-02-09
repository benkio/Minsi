module Model.State.StateFromHtml where

import Prelude

import Components.HTMLTableElement (loadSubtitlesFromTable)
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), loadComponents)
import Components.HtmlIds (youtubeUrlId, outputFilenameId, artistId, titleId, cutStartId)
import Components.Window (getDocument)
import Conversion.String (capitalize)
import Data.Array (length, (!!))
import Data.Either (either)
import Data.Int (toNumber)
import Data.Maybe (fromJust)
import Data.String.Common (trim, toUpper)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (Tuple(..))
import Data.URL (URL)
import Data.Validation.Semigroup (V, validation, toEither)
import Effect (Effect)
import HTMLInputElement as HTMLInputElement
import HTMLTableCellElement (valueFromInputTableCell, valueFromSelectTableCell, valueFromTextAreaTableCell)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.State.State (State(..), DurationRange(..), WURL(..), Subtitle(..))
import Model.ValidationErrors (ValidationErrors, toMap)
import Parse.Font (parseFont, parseColor, parsePosition)
import Partial.Unsafe (unsafePartial)
import Validations.CutVideoValidation (cutVideoValidation)
import Validations.OutputFilenameValidation (outputFilenameValidation, normalizeOutputFilename)
import Validations.YoutubeValidation (youtubeUrlValidation)
import Web.DOM.HTMLCollection as HC
import Web.HTML.HTMLInputElement (HTMLInputElement, value, valueAsNumber, checked)
import Web.HTML.HTMLTableRowElement as HTR

getCurrentState :: Effect (Tuple State HtmlComponents)
getCurrentState = do
 doc <- getDocument
 components <- loadComponents doc
 stateV <- fromHtmlInputs components.htmlInputs
 state <- (either (throwMinsiError <<< InvalidInputs <<< toMap) pure <<< toEither) stateV
 pure $ Tuple state components

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
  filenameV <- value filenameInput <#> outputFilenameValidation outputFilenameId
  reverseLoopValue <- checked reverseLoopInput
  artistV <- HTMLInputElement.nonEmptyFromHtmlInput artistInput artistId
  titleV <- HTMLInputElement.nonEmptyFromHtmlInput titleInput titleId
  subtitles <- loadSubtitlesFromTable loadSubtitleFromRow subtitleTable
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
        , filename: normalizeOutputFilename filename
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
    startValue <- valueFromInputTableCell index "SubtitleTableStartCell" 0 startCell
    endValue <- valueFromInputTableCell index "SubtitleTableEndCell" 0 endCell
    valueText <- valueFromTextAreaTableCell index "SubtitleTableValueCell" valueCell
    fontValue <- valueFromSelectTableCell index "SubtitleTableFontCell" fontCell
    fontSizeValue <- valueFromInputTableCell index "SubtitleTableFontSizeCell" 48 fontSizeCell
    colorValue <- valueFromSelectTableCell index "SubtitleTableColorCell" colorCell
    positionValue <- valueFromSelectTableCell index "SubtitleTablePositionCell" positionCell
    validation
      (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
      ( \_ -> pure $ Subtitle
          { videoPosition: DurationRange
              { start: Milliseconds (toNumber startValue)
              , end: Milliseconds (toNumber endValue)
              }
          , value: (toUpper <<< trim) valueText
          , font: parseFont fontValue
          , fontSize: fontSizeValue
          , color: parseColor colorValue
          , screenPosition: parsePosition positionValue
          }
      )
      (cutVideoValidation ("[Subtitle row " <> show index <> "]") (toNumber startValue) (toNumber endValue))
