module Handlers.ApplyButtonHandler where

import Prelude

import Components.HtmlComponents (HtmlComponents, HtmlInputs(..))
import Components.HtmlIdAndClasses (loadingModalId, videoSourceId)
import Components.HtmlVisualElements (showHiddenElements)
import Components.Modal (hideModal, showModal)
import Components.Window (scrollToElement)
import Data.Array (dropWhile)
import Data.Newtype (unwrap)
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
import Handlers.ResultVideo.MediaSrc (setResultMediaSrc)
import Handlers.Subtitles.SubtitleMaxValues (setSubtitleTableMaxValues)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ProcessStatus (ProcessStatus(..))
import Model.State.State (Source(..), State, isLocalFile)
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI
import Web.File.File (name)

setApplyButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setApplyButtonHandler applyButton = genericErrorsHandler $ do
  applyButtonEvL <- eventListener applyButtonEventListener
  addEventListener E.click applyButtonEvL false applyButtonEventTarget
  where
  applyButtonEventTarget = toEventTarget (HB.toElement applyButton)

applyButtonEventListener :: Event -> Effect Unit
applyButtonEventListener _ = genericErrorsHandler $ do
  stateComponents <- getCurrentState
  let state = fst stateComponents
  let components = snd stateComponents
  let uploadLocalFileInput = (unwrap components.htmlInputs).uploadLocalFile
  showModal loadingModalId
  runAff_
    (\result -> genericErrorsHandlerEither result) $
    finally (liftEffect (finallyHandlers components state)) (applyButtonLogic state uploadLocalFileInput)

applyButtonLogic :: State -> HI.HTMLInputElement -> Aff Unit
applyButtonLogic state uploadLocalFileInput = genericErrorsHandler $ do
  let
    uploadLocalFile = (unwrap state).uploadLocalFile
    filename = (unwrap state).filename
    source = (unwrap state).source
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

finallyHandlers :: HtmlComponents -> State -> Effect Unit
finallyHandlers components state = do
  let reverseLoop = (unwrap state).reverseLoop
  let filename = (unwrap state).filename
  log "return from server, show elements and set src"
  showHiddenElements components.htmlVisualElements reverseLoop
  log "hide modal, and scroll"
  hideModal loadingModalId
  scrollToElement videoSourceId
  let
    resultVideo = (unwrap components.htmlOutputs).resultVideo
    resultAudio = (unwrap components.htmlOutputs).resultAudio
    videoSourceElement = (unwrap components.htmlInputs).videoSource
  setResultMediaSrc filename videoSourceElement resultVideo resultAudio
  let HtmlInputs { subtitleTable, subtitleRow } = components.htmlInputs
  setSubtitleTableMaxValues state subtitleTable subtitleRow
