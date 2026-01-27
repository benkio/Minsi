module Handlers.ApplyButtonHandler where

import Prelude

import Data.Tuple (Tuple(..), fst, snd)
import Model.State.State (State)
import Components.HtmlComponents (HtmlComponents, HtmlVisualElements(..), loadComponents)
import Components.HtmlIds (loadingModalId, videoSourceId)
import Components.Modal (hideLoadingModal, showLoadingModal)
import Components.Window (getDocument)
import Constants (mp4)
import Control.Monad.Rec.Class (Step(..), tailRecM)
import Data.Either (either)
import Data.Newtype (unwrap)
import Data.Time.Duration (Milliseconds(..))
import Data.Validation.Semigroup (toEither)
import Effect (Effect)
import Effect.Aff (Aff, delay, runAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Endpoints.Compute (callCompute)
import Endpoints.Status (callStatus)
import Handers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.ProcessStatus (ProcessStatus(..))
import Model.State.StateFromHtml (fromHtmlInputs)
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element (toEventTarget)
import Web.DOM.Element as Element
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLDivElement as HTMLDivElement
import Web.HTML.HTMLMediaElement (load, pause, setSrc)
import Web.HTML.HTMLVideoElement (HTMLVideoElement, toHTMLMediaElement)
import Web.HTML.Location (setHash)
import Web.HTML.Window (location)
import Effect.Now (now)
import Data.DateTime.Instant (unInstant)

setApplyButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setApplyButtonHandler applyButton = do
  applyButtonEvL <- eventListener applyButtonEventListener
  addEventListener E.click applyButtonEvL false applyButtonEventTarget
  where
  applyButtonEventTarget = toEventTarget (HB.toElement applyButton)

applyButtonEventListener :: Event -> Effect Unit
applyButtonEventListener _ = genericErrorsHandler $ do
  stateComponents <- getCurrentState
  let state = fst stateComponents
  let components = snd stateComponents
  let filename = (unwrap state).filename
  let filepath = mp4 filename
  showLoadingModal loadingModalId
  runAff_
    ( \result -> do
        genericErrorsHandlerEither result
        log "return from server, show elements and set src"
        showHiddenElements components.htmlVisualElements
        log "hide modal, and scroll"
        hideLoadingModal loadingModalId
        scrollToVideoSource
        let videoMediaElement = (unwrap components.htmlOutputs).resultVideo
        setVideoSrc filepath videoMediaElement
    )
    (void (callCompute state) *> waitForStatus filename)

waitForStatus :: String -> Aff Unit
waitForStatus filename = tailRecM pollStatus unit
  where
  pollStatus _ = do
    response <- callStatus filename
    case response.status of
      Pending -> delay (Milliseconds 500.0) $> Loop unit
      Succeed -> pure $ Done unit
      Failed -> liftEffect $ throwMinsiError (ComputeFailed "Video download failed")

setVideoSrc :: String -> HTMLVideoElement -> Effect Unit
setVideoSrc filepath video = do
  (Milliseconds m) <- unInstant <$> now
  let cacheBustedPath = filepath <> "?t=" <> show m
  pause videoMediaElement
  setSrc cacheBustedPath videoMediaElement
  load videoMediaElement
  where
  videoMediaElement = toHTMLMediaElement video

showHiddenElements :: HtmlVisualElements -> Effect Unit
showHiddenElements (HtmlVisualElements { videoSourceRow, videoRow, subtitlesRow, playbackPositionResultRow }) = do
  removeClass "d-none" videoSourceRow
  removeClass "d-none" videoRow
  removeClass "d-none" subtitlesRow
  removeClass "d-none" playbackPositionResultRow

removeClass :: String -> HTMLDivElement.HTMLDivElement -> Effect Unit
removeClass className div = do
  let element = HTMLDivElement.toElement div
  classList <- Element.classList element
  DOMTokenList.remove classList className

scrollToVideoSource :: Effect Unit
scrollToVideoSource = do
  w <- window
  loc <- location w
  setHash ("#" <> videoSourceId) loc

getCurrentState :: Effect (Tuple State HtmlComponents)
getCurrentState = do
  doc <- getDocument
  components <- loadComponents doc
  stateV <- fromHtmlInputs components.htmlInputs
  state <- (either (throwMinsiError <<< InvalidInputs) pure <<< toEither) stateV
  pure $ Tuple state components
