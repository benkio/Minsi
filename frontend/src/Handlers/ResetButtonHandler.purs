module Handlers.ResetButtonHandler where

import Prelude

import Effect (Effect)
import Effect.Aff (runAff_)
import Endpoints.Reset (callReset)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_resetButton)
import Data.Lens (view)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB

setResetButtonHandler :: Effect Unit
setResetButtonHandler = genericErrorsHandler $ do
  components <- loadComponents
  let resetButton = view _resetButton components
  resetButtonEventL <- eventListener resetButtonEventListener
  addEventListener E.click resetButtonEventL false (toEventTarget (HB.toElement resetButton))

resetButtonEventListener :: Event -> Effect Unit
resetButtonEventListener _ = do
  runAff_ genericErrorsHandlerEither callReset
