module Handlers.ApplyButtonHandler
  ( setApplyButtonHandler
  , applyButtonEventListener
  , revealComputedResultPanels
  , syncApplyResultMediaAndSubtitleCeilings
  ) where

import Prelude

import Components.HtmlComponents (HtmlComponents, loadComponents)
import Components.HtmlComponents.Lenses (_applyButton, _resultAudio, _resultVideo, _subtitleRowTemplate, _subtitleTable, _uploadLocalFile, _videoSource)
import Components.HtmlIdAndClasses (loadingModalId, videoSourceId)
import Components.HtmlVisualElements (showHiddenElements)
import Components.Modal (hideModal, showModal)
import Components.Window (scrollToElement)
import Data.Array (dropWhile)
import Data.Lens (view)
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Data.Tuple (fst, snd)
import Effect (Effect)
import Effect.Aff (Aff, runAff_, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Endpoints.Compute (callCompute)
import Endpoints.StatusPolling (waitForStatus)
import Endpoints.Upload (callUpload)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Handlers.ResultMedia.MediaSrc (setResultMediaSrc)
import Handlers.Subtitles.SubtitleMaxValues (setSubtitleTableMaxValues)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ProcessStatus (ProcessStatus(..))
import Model.State.State (Source(..), State(..), isLocalFile)
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.File.File (name)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI

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
  showModal loadingModalId true
  runAff_
    (\result -> genericErrorsHandlerEither result) $
    finally (liftEffect (finallyHandlers components state)) (applyButtonLogic state uploadLocalFileInput)

applyButtonLogic :: State -> HI.HTMLInputElement -> Aff Unit
applyButtonLogic (State rec) uploadLocalFileInput = genericErrorsHandler $ do
  let state = State rec
  let
    uploadLocalFile = rec.uploadLocalFile
    filename = rec.filename
    source = rec.source
  when (uploadLocalFile && isLocalFile source)
    ( uploadLocalFileLogic source filename uploadLocalFileInput
        *> waitForStatus filename LocalFileUploaded
    )
  void (callCompute state)
  waitForStatus filename Succeed

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
revealComputedResultPanels components state@(State rec) = do
  showHiddenElements components.htmlVisualElements rec.reverseLoop
  syncApplyResultMediaAndSubtitleCeilings components state

finallyHandlers :: HtmlComponents -> State -> Effect Unit
finallyHandlers components state@(State rec) = do
  log "return from server, show elements and set src"
  showHiddenElements components.htmlVisualElements rec.reverseLoop
  log "hide modal, and scroll"
  hideModal loadingModalId
  syncApplyResultMediaAndSubtitleCeilings components state
