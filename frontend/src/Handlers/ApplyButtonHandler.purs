module Handlers.ApplyButtonHandler
  ( setApplyButtonHandler
  , applyButtonEventListener
  , revealComputedResultPanels
  , syncApplyResultMediaAndSubtitleCeilings
  ) where

import Prelude

import Components.HTMLTableElement (getRows, setRows)
import Components.HTMLTableRowElement (setTableCellValue)
import Components.HTMLTemplateElement (getRow)
import Components.HtmlComponents (HtmlComponents, loadComponents)
import Components.LoadingModal (loadingModalExtraContentRotation)
import Components.HtmlComponents.Lenses (_applyButton, _resultAudio, _resultVideo, _subtitleRowTemplate, _subtitleTable, _uploadLocalFile, _videoSource)
import Components.HtmlIdAndClasses (loadingModalId, videoSourceId)
import Components.HtmlVisualElements (showHiddenElements)
import Components.Modal (hideModal, showModal)
import Components.Window (scrollToElement)
import Data.Array (dropWhile, null)
import Data.Int (floor)
import Data.Maybe (Maybe(..))
import Data.Lens (view)
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Data.Time.Duration (Milliseconds(..))
import Data.Tuple (fst, snd)
import Data.Traversable (traverse, traverse_)
import Effect (Effect)
import Effect.Aff (Aff, runAff_, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Endpoints.Compute (callCompute)
import Endpoints.StatusPolling (waitForStatus)
import Endpoints.Subtitles (callSubtitles)
import Endpoints.Upload (callUpload)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Handlers.ResultMedia.MediaSrc (setResultMediaSrc)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (addRemoveSubtitleListenerToRow)
import Handlers.Subtitles.SubtitleMaxValues (setSubtitleTableMaxValues)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Parse.Font (formatFontAndColor, formatPosition)
import Domain.ProcessStatus (ProcessStatus(..))
import Model.State.State (DurationRange(..), Source(..), State(..), Subtitle(..), isLocalFile)
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (fromNode, toEventTarget)
import Web.DOM.Node (deepClone)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.File.File (name)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLTableRowElement as HTR

setApplyButtonHandler :: Effect Unit
setApplyButtonHandler = genericErrorsHandler $ do
  components <- loadComponents
  let applyButton = view _applyButton components
  applyButtonEvL <- eventListener applyButtonEventListener
  addEventListener E.click applyButtonEvL false (toEventTarget (HB.toElement applyButton))

applyButtonEventListener :: Event -> Effect Unit
applyButtonEventListener _ = genericErrorsHandler $ do
  stateComponents <- getCurrentState
  let state = fst stateComponents
  let components = snd stateComponents
  let uploadLocalFileInput = view _uploadLocalFile components
  showModal loadingModalId (Just 15240)
  runAff_
    (\result -> genericErrorsHandlerEither result) $
    finally (liftEffect (finallyHandlers components state)) (applyButtonLogic state uploadLocalFileInput components)

applyButtonLogic :: State -> HI.HTMLInputElement -> HtmlComponents -> Aff Unit
applyButtonLogic (State rec) uploadLocalFileInput components = genericErrorsHandler $ do
  let state = State rec
  let
    uploadLocalFile = rec.uploadLocalFile
    filename = rec.filename
    source = rec.source
  when (uploadLocalFile && isLocalFile source)
    ( uploadLocalFileLogic source filename uploadLocalFileInput
        *> waitForStatus filename (LocalFileUploaded "") Nothing
    )
  void (callCompute state)
  waitForStatus filename Succeed (Just loadingModalExtraContentRotation)
  subtitlesResponse <- callSubtitles filename
  subtitleRows <- liftEffect $ getRows (view _subtitleTable components)
  let shouldHydrate = null rec.subtitles || null subtitleRows
  when shouldHydrate do
    unless (null subtitlesResponse.subtitles)
      $ liftEffect
      $ applyGeneratedSubtitlesToTable components subtitlesResponse.subtitles

uploadLocalFileLogic :: Source -> String -> HI.HTMLInputElement -> Aff Unit
uploadLocalFileLogic (LocalFile file) filename uploadLocalFileInput = genericErrorsHandler $ do
  let diskFilename = name file
  let
    diskFileExt = fromCharArray $ dropWhile (_ /= '.') (toCharArray diskFilename)
    fullFileName = filename <> diskFileExt
  liftEffect $ log $ "[ApplyButtonHandler] Upload Local File " <> fullFileName
  void $ callUpload file fullFileName
  liftEffect do
    log "[ApplyButtonHandler] Set uploadLocalFileInput to False"
    HI.setChecked false uploadLocalFileInput
uploadLocalFileLogic x _ _ = liftEffect $ throwMinsiError (InvalidInput "StateSource" ("Expected LocalFile, got " <> show x))

applyGeneratedSubtitlesToTable :: HtmlComponents -> Array Subtitle -> Effect Unit
applyGeneratedSubtitlesToTable components generatedSubtitles = do
  let
    subtitleTable = view _subtitleTable components
    subtitleRow = view _subtitleRowTemplate components
  subtitleTemplateRow <- getRow subtitleRow
  newRows <- traverse (cloneAndFillGeneratedSubtitleRow subtitleTemplateRow) generatedSubtitles
  setRows newRows subtitleTable
  traverse_ addRemoveSubtitleListenerToRow newRows

cloneAndFillGeneratedSubtitleRow :: HTR.HTMLTableRowElement -> Subtitle -> Effect HTR.HTMLTableRowElement
cloneAndFillGeneratedSubtitleRow templateRow subtitle = do
  clonedNode <- deepClone (HTR.toNode templateRow)
  row <- case fromNode clonedNode >>= HTR.fromElement of
    Nothing -> throwMinsiError (HTMLElementNotFound "generatedSubtitleRowClone")
    Just value -> pure value
  generatedSubtitleToRowValues subtitle row
  pure row

generatedSubtitleToRowValues :: Subtitle -> HTR.HTMLTableRowElement -> Effect Unit
generatedSubtitleToRowValues (Subtitle { videoPosition: (DurationRange { start, end }), value, font, fontSize, color, screenPosition }) row = do
  let
    startMillis = case start of Milliseconds n -> n
    endMillis = case end of Milliseconds n -> n
  setTableCellValue "Start" (show (floor startMillis)) row
  setTableCellValue "End" (show (floor endMillis)) row
  setTableCellValue "Content" value row
  setTableCellValue "FontColor" (formatFontAndColor font color) row
  setTableCellValue "Size" (show fontSize) row
  setTableCellValue "Position" (formatPosition screenPosition) row

-- | Scroll to outputs, attach result URLs, clamp subtitle timings — same fragment as Apply’s `finally` after the loading modal hides.
syncApplyResultMediaAndSubtitleCeilings :: HtmlComponents -> State -> Effect Unit
syncApplyResultMediaAndSubtitleCeilings components state@(State rec) = do
  let
    resultVideo = view _resultVideo components
    resultAudio = view _resultAudio components
    videoSourceElement = view _videoSource components
    subtitleTable = view _subtitleTable components
    subtitleRowTemplate = view _subtitleRowTemplate components
  setResultMediaSrc rec.filename videoSourceElement resultVideo resultAudio
  scrollToElement videoSourceId
  setSubtitleTableMaxValues state subtitleTable subtitleRowTemplate

-- | Drops `d-none` on result/toolbar strips (respecting GIF reverse-loop), then runs `syncApplyResultMediaAndSubtitleCeilings`.
revealComputedResultPanels :: HtmlComponents -> State -> Effect Unit
revealComputedResultPanels components (State rec) = do
  showHiddenElements components.htmlVisualElements rec.reverseLoop

finallyHandlers :: HtmlComponents -> State -> Effect Unit
finallyHandlers components state@(State rec) = do
  log "return from server, show elements and set src"
  showHiddenElements components.htmlVisualElements rec.reverseLoop
  log "hide modal, and scroll"
  hideModal loadingModalId
  syncApplyResultMediaAndSubtitleCeilings components state
