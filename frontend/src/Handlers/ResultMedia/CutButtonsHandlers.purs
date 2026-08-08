module Handlers.ResultMedia.CutButtonsHandlers where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_setResultCutEndButton, _setResultCutStartButton)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB

setResultCutButtonsHandlers :: Effect Unit
setResultCutButtonsHandlers = genericErrorsHandler $ do
  components <- loadComponents
  let
    setResultCutStartButton = view _setResultCutStartButton components
    setResultCutEndButton = view _setResultCutEndButton components
  startButtonEvL <- eventListener setResultCutStartButtonEvL
  endButtonEvL <- eventListener setResultCutEndButtonEvL
  addEventListener E.click startButtonEvL false (toEventTarget (HB.toElement setResultCutStartButton))
  addEventListener E.click endButtonEvL false (toEventTarget (HB.toElement setResultCutEndButton))

setResultCutStartButtonEvL :: Event -> Effect Unit
setResultCutStartButtonEvL _ = log "[ResultMedia] set result cut start button clicked"

setResultCutEndButtonEvL :: Event -> Effect Unit
setResultCutEndButtonEvL _ = log "[ResultMedia] set result cut end button clicked"
