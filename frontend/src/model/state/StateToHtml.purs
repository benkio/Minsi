module Model.State.StateToHtml where

import Prelude

import Components.HTMLTableElement (setRows)
import Components.HTMLTableRowElement (setTableCellValue)
import Components.HTMLTemplateElement (getRow)
import Components.HtmlComponents (HtmlInputs(..), loadComponents)
import Data.Int (floor)
import Data.Maybe (maybe)
import Data.Time.Duration (Milliseconds(..))
import Data.Traversable (traverse, traverse_)
import Data.URL (toString)
import Effect (Effect)
import Handlers.ApplyButtonHandler (revealComputedResultPanels)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (addRemoveSubtitleListenerToRow)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (State(..), DurationRange(..), Subtitle(..), Source(..), WURL(..), shiftSubtitle)
import Parse.Font (formatFontAndColor, formatPosition)
import Web.DOM.Element (fromNode)
import Web.DOM.Node (deepClone)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTableRowElement as HTR

loadCurrentState :: State -> Effect Unit
loadCurrentState (State s) = do
  components <- loadComponents
  let inputs = components.htmlInputs
  applySubtitleOffsetToHtml inputs
  applyCutVideoToHtml s.cutVideo inputs
  applySourceToHtml s.source inputs
  applyFilenameToHtml s.filename inputs
  applyReverseLoopToHtml s.reverseLoop inputs
  applyUploadLocalFileToHtml s.uploadLocalFile inputs
  applyTitleToHtml s.title inputs
  applyArtistToHtml s.artist inputs
  applySubtitlesToHtml s.subtitles inputs
  revealComputedResultPanels components $ State s

applySubtitleOffsetToHtml :: HtmlInputs -> Effect Unit
applySubtitleOffsetToHtml (HtmlInputs { subtitleOffset }) =
  HI.setValue "0.0" subtitleOffset

applyCutVideoToHtml :: DurationRange -> HtmlInputs -> Effect Unit
applyCutVideoToHtml (DurationRange { start: startMs, end: endMs }) (HtmlInputs { cutStart, cutEnd }) = do
  HI.setValue (millisecondsInputString startMs) cutStart
  HI.setValue (millisecondsInputString endMs) cutEnd

applySourceToHtml :: Source -> HtmlInputs -> Effect Unit
applySourceToHtml source (HtmlInputs { inputSource, youtubeUrl }) =
  case source of
    WebURL (WURL url) -> do
      HS.setValue "youtubeUrl" inputSource
      HI.setValue (toString url) youtubeUrl
    LocalFile _ ->
      -- Cannot repopulate the file picker for security reasons; align mode with empty YouTube URL.
      do
        HS.setValue "localFile" inputSource
        HI.setValue "" youtubeUrl

applyFilenameToHtml :: String -> HtmlInputs -> Effect Unit
applyFilenameToHtml filename (HtmlInputs { filename: filenameInput }) =
  HI.setValue filename filenameInput

applyReverseLoopToHtml :: Boolean -> HtmlInputs -> Effect Unit
applyReverseLoopToHtml flag (HtmlInputs { reverseLoop: reverseLoopInput }) =
  HI.setChecked flag reverseLoopInput

applyUploadLocalFileToHtml :: Boolean -> HtmlInputs -> Effect Unit
applyUploadLocalFileToHtml flag (HtmlInputs { uploadLocalFile: uploadLocalFileInput }) =
  HI.setChecked flag uploadLocalFileInput

applyTitleToHtml :: String -> HtmlInputs -> Effect Unit
applyTitleToHtml titleText (HtmlInputs { title: titleInput }) =
  HI.setValue titleText titleInput

applyArtistToHtml :: String -> HtmlInputs -> Effect Unit
applyArtistToHtml artistText (HtmlInputs { artist: artistInput }) =
  HI.setValue artistText artistInput

applySubtitlesToHtml :: Array Subtitle -> HtmlInputs -> Effect Unit
applySubtitlesToHtml subtitles (HtmlInputs { subtitleOffset, subtitleTable, subtitleRow }) = do
  offsetMillis <- HI.valueAsNumber subtitleOffset
  let
    subtitlesForDom =
      map (shiftSubtitle (Milliseconds (-offsetMillis))) subtitles
  subtitleTemplateRow <- getRow subtitleRow
  newRows <- traverse (cloneAndFillSubtitleRow subtitleTemplateRow) subtitlesForDom
  setRows newRows subtitleTable
  traverse_ addRemoveSubtitleListenerToRow newRows

millisecondsInputString :: Milliseconds -> String
millisecondsInputString (Milliseconds n) = show $ floor n

cloneAndFillSubtitleRow :: HTR.HTMLTableRowElement -> Subtitle -> Effect HTR.HTMLTableRowElement
cloneAndFillSubtitleRow templateRow sub = do
  clonedNode <- deepClone (HTR.toNode templateRow)
  row <-
    maybe (throwMinsiError (HTMLElementNotFound "subtitleRowClone")) pure
      (fromNode clonedNode >>= HTR.fromElement)
  subtitleToRowValues sub row
  pure row

subtitleToRowValues :: Subtitle -> HTR.HTMLTableRowElement -> Effect Unit
subtitleToRowValues
  (Subtitle { videoPosition, value, font, fontSize, color, screenPosition })
  row =
  do
    let
      DurationRange { start: s, end: e } = videoPosition
    setTableCellValue "Start" (millisecondsInputString s) row
    setTableCellValue "End" (millisecondsInputString e) row
    setTableCellValue "Content" value row
    setTableCellValue "FontColor" (formatFontAndColor font color) row
    setTableCellValue "Size" (show fontSize) row
    setTableCellValue "Position" (formatPosition screenPosition) row
