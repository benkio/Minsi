module Handlers.ApplyButtonHandler where

import Effect.Console (log)
import Components.HtmlComponents (HtmlVisualElements(..), loadComponents)
import Components.HtmlIds (loadingModalId, videoSourceId)
import Components.Modal (hideLoadingModal, showLoadingModal)
import Components.Window (getDocument)
import Data.Either (either)
import Data.Time.Duration (Milliseconds(..))
import Data.Validation.Semigroup (toEither)
import Effect (Effect)
import Effect.Aff (delay, runAff_)
import Effect.Class (liftEffect)
import Endpoints.Compute (callCompute)
import Handers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.StateFromHtml (fromHtmlInputs)
import Prelude
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element (toEventTarget)
import Web.DOM.Element as Element
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLDivElement as HTMLDivElement
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
  runAff_ genericErrorsHandlerEither do
    response <- callCompute state
    liftEffect do
      hideLoadingModal loadingModalId
      showHiddenElements components.htmlVisualElements
      scrollToVideoSource
  pure unit

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
