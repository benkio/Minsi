module Model.State.StateFromHtml where

import Prelude

import Components.HTMLTableElement (loadSubtitlesFromTable)
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), loadComponents)
import Components.HtmlIds (youtubeUrlId, outputFilenameId, artistId, titleId, cutStartId, localFileId, inputSourceId)
import Conversion.OutputFilename (normalizeOutputFilename)
import Conversion.String (capitalize)
import Data.Array (length, (!!))
import Data.Either (either)
import Data.Int (fromString, toNumber)
import Data.Maybe (fromJust, fromMaybe, Maybe(..))
import Data.String.Common (trim, toUpper)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (Tuple(..))
import Data.Validation.Semigroup (V, andThen, invalid, toEither, validation)
import Effect (Effect)
import HTMLInputElement as HTMLInputElement
import HTMLTableCellElement (valueFromInputTableCell, valueFromSelectTableCell, valueFromTextAreaTableCell)
import Handers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (State(..), DurationRange(..), WURL(..), Source(..), Subtitle(..))
import Model.ValidationErrors (ValidationErrors, toMap, fromSingleton)
import Parse.Font (parseFontAndColor, parsePosition)
import Partial.Unsafe (unsafePartial)
import Validations.DurationRangeValidation (durationRangeValidation)
import Validations.LetterNumberSpaceValidation (letterNumberSpaceValidation)
import Validations.LetterNumberUnderscoreValidation (letterNumberUnderscoreValidation)
import Validations.YoutubeValidation (youtubeUrlValidation)
import Web.DOM.HTMLCollection as HC
import Web.File.FileList (item)
import Web.HTML.HTMLInputElement (HTMLInputElement, valueAsNumber, checked)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement (HTMLSelectElement)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTableRowElement as HTR

getCurrentState :: Effect (Tuple State HtmlComponents)
getCurrentState = genericErrorsHandler $ do
  components <- loadComponents
  stateV <- fromHtmlInputs components.htmlInputs
  state <- (either (throwMinsiError <<< InvalidInputs <<< toMap) pure <<< toEither) stateV
  pure $ Tuple state components

fromHtmlInputs :: HtmlInputs -> Effect (V ValidationErrors State)
fromHtmlInputs
  ( HtmlInputs
      { cutStart
      , cutEnd
      , youtubeUrl: youtubeUrlInput
      , localFile: localFileInput
      , uploadLocalFile: uploadLocalFileInput
      , inputSource: inputSourceSelect
      , filename: filenameInput
      , reverseLoop: reverseLoopInput
      , artist: artistInput
      , title: titleInput
      , subtitleTable
      }
  ) = do
  cutVideoV <- cutVideoFromHtmlRange cutStart cutEnd
  sourceV <- sourceFromHTMLInput inputSourceSelect youtubeUrlInput localFileInput
  filenameV <- HI.value filenameInput <#> letterNumberUnderscoreValidation outputFilenameId
  reverseLoopValue <- checked reverseLoopInput
  uploadLocalFileValue <- checked uploadLocalFileInput
  artistV <- HTMLInputElement.nonEmptyFromHtmlInput artistInput artistId <#> (_ `andThen` letterNumberSpaceValidation artistId)
  titleV <- HTMLInputElement.nonEmptyFromHtmlInput titleInput titleId <#> (_ `andThen` letterNumberSpaceValidation titleId)
  subtitles <- loadSubtitlesFromTable loadSubtitleFromRow subtitleTable
  pure $ ado
    cutVideo <- cutVideoV
    source <- sourceV
    filename <- filenameV
    artist <- artistV
    title <- titleV
    in
      State
        { cutVideo: cutVideo
        , source: source
        , filename: normalizeOutputFilename filename
        , reverseLoop: reverseLoopValue
        , uploadLocalFile: uploadLocalFileValue
        , artist: capitalize artist
        , title: capitalize title
        , subtitles: subtitles
        }

cutVideoFromHtmlRange :: HTMLInputElement -> HTMLInputElement -> Effect (V ValidationErrors DurationRange)
cutVideoFromHtmlRange cutStart cutEnd = do
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  pure $ durationRangeValidation cutStartId start end

sourceFromHTMLInput :: HTMLSelectElement -> HTMLInputElement -> HTMLInputElement -> Effect (V ValidationErrors Source)
sourceFromHTMLInput inputSourceSelect youtubeUrlComponent localFileComponent = do
  urlString <- HI.value youtubeUrlComponent
  inputSource <- HS.value inputSourceSelect
  let
    youtubeValidation = youtubeUrlValidation youtubeUrlId urlString <#> \url -> WebURL (WURL url)
  case inputSource of
    "youtubeUrl" -> pure youtubeValidation
    "localFile" -> do
      filesMaybe <- HI.files localFileComponent
      case filesMaybe >>= item 0 of
        Nothing -> pure $ invalid (fromSingleton localFileId "No file selected")
        Just file -> pure $ pure (LocalFile file)
    v -> pure $ invalid (fromSingleton inputSourceId ("Unrecognized value: " <> v))

loadSubtitleFromRow :: Int -> HTR.HTMLTableRowElement -> Effect Subtitle
loadSubtitleFromRow index row = do
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  if length cellArray /= 7 then throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: Unexpected number of columns" <> (show (length cellArray))))
  else do
    let
      startCell = unsafePartial fromJust (cellArray !! 0)
      endCell = unsafePartial fromJust (cellArray !! 1)
      valueCell = unsafePartial fromJust (cellArray !! 2)
      fontColorCell = unsafePartial fromJust (cellArray !! 3)
      fontSizeCell = unsafePartial fromJust (cellArray !! 4)
      positionCell = unsafePartial fromJust (cellArray !! 5)
    startValue <- valueFromInputTableCell index "SubtitleTableStartCell" 0 startCell
    endValue <- valueFromInputTableCell index "SubtitleTableEndCell" 0 endCell
    valueText <- valueFromTextAreaTableCell index "SubtitleTableValueCell" valueCell
    fontColorValue <- valueFromSelectTableCell index "SubtitleTableFontColorCell" fontColorCell
    let { font: fontValue, color: colorValue } = parseFontAndColor fontColorValue
    fontSizeString <- valueFromSelectTableCell index "SubtitleTableFontSizeCell" fontSizeCell
    let fontSizeValue = fromMaybe 36 (fromString fontSizeString)
    positionValue <- valueFromSelectTableCell index "SubtitleTablePositionCell" positionCell
    validation
      (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
      ( \_ -> pure $ Subtitle
          { videoPosition: DurationRange
              { start: Milliseconds (toNumber startValue)
              , end: Milliseconds (toNumber endValue)
              }
          , value: (toUpper <<< trim) valueText
          , font: fontValue
          , fontSize: fontSizeValue
          , color: colorValue
          , screenPosition: parsePosition positionValue
          }
      )
      (durationRangeValidation ("[Subtitle row " <> show index <> "]") (toNumber startValue) (toNumber endValue))
