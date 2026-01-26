module Handlers.ApplyButtonHandler where

import Effect.Aff (delay, launchAff_)

import Data.Time.Duration (Milliseconds(..))

import Effect.Console (log)

import Prelude

import Components.HtmlComponents (HtmlOutputs(..), HtmlVisualElements(..), loadComponents)
import Components.HtmlIds (loadingModalId, videoSourceId)
import Components.Modal (hideLoadingModal, showLoadingModal)
import Components.Window (getDocument)
import Constants (mp4)
import Data.Either (either)
import Data.Newtype (unwrap)
import Data.Validation.Semigroup (toEither)
import Effect (Effect)
import Effect.Aff (runAff_)
import Endpoints.Compute (callCompute)
import Handers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (State)
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
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLMediaElement (setSrc, load)
import Web.HTML.HTMLVideoElement (toHTMLMediaElement)
import Web.HTML.Location (setHash)
import Web.HTML.Window (location)

setApplyButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setApplyButtonHandler applyButton = do
  applyButtonEvL <- eventListener applyButtonEventListener
  addEventListener E.click applyButtonEvL false applyButtonEventTarget
  where
    applyButtonEventTarget = toEventTarget (HB.toElement applyButton)

applyButtonEventListener :: Event -> Effect Unit
applyButtonEventListener _ = genericErrorsHandler $ do
  doc <- getDocument
  components <- loadComponents doc
  stateV <- fromHtmlInputs components.htmlInputs
  state <- (either (throwMinsiError <<< InvalidInputs) pure <<< toEither) stateV
  showLoadingModal loadingModalId
  runAff_ (\result -> do
    genericErrorsHandlerEither result
    log "return from server, show elements and set src"
    showHiddenElements components.htmlVisualElements
    let videoFilePath = mp4 (unwrap state).filename
        videoMediaElement = (unwrap components.htmlOutputs).resultVideo
    setVideoSrc videoFilePath videoMediaElement
    log "hide modal, and scroll"
    hideLoadingModal loadingModalId
    scrollToVideoSource
  ) (void (callCompute state) *> delay (Milliseconds 500.0))

setVideoSrc :: String -> HTMLVideoElement -> Effect Unit
setVideoSrc filepath video = do
  setSrc "" videoMediaElement
  load videoMediaElement
  setSrc filepath videoMediaElement
  load videoMediaElement
  where
    videoMediaElement = toHTMLMediaElement video

showHiddenElements :: HtmlVisualElements -> Effect Unit
showHiddenElements (HtmlVisualElements { videoSourceRow, videoRow, subtitlesRow }) = do
  removeClass "d-none" videoSourceRow
  removeClass "d-none" videoRow
  removeClass "d-none" subtitlesRow

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
