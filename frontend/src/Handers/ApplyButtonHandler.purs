module Handlers.ApplyButtonHandler where

import Components.HtmlComponents (loadComponents, HtmlVisualElements(..))
import Components.HtmlIds (loadingModalId, videoSourceId)
import Components.Modal (showLoadingModal, hideLoadingModal)
import Components.Window (getDocument)
import Data.Either (Either(..))
import Data.Time.Duration (Milliseconds(..))
import Data.Validation.Semigroup (toEither)
import Effect (Effect)
import Effect.Aff (delay, launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Handers.ErrorHandlers (genericErrorsHandler)
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
  case toEither stateV of
    Left errors -> throwMinsiError (InvalidInputs errors)
    Right _ -> log ("State converted")
  showLoadingModal loadingModalId
  launchAff_ do
    delay (Milliseconds 5000.0)
    liftEffect $ do
      hideLoadingModal loadingModalId
      showHiddenElements components.htmlVisualElements
      scrollToVideoSource
  pure unit


showHiddenElements :: HtmlVisualElements -> Effect Unit
showHiddenElements (HtmlVisualElements {videoSourceRow, videoRow, subtitlesRow}) = do
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
