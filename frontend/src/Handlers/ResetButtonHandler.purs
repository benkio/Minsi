module Handlers.ResetButtonHandler where

import Prelude

import Effect (Effect)
import Effect.Aff (runAff_)
import Endpoints.Reset (callReset)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB

setResetButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setResetButtonHandler resetButton = genericErrorsHandler $ do
  resetButtonEventL <- eventListener resetButtonEventListener
  addEventListener E.click resetButtonEventL false (toEventTarget (HB.toElement resetButton))

resetButtonEventListener :: Event -> Effect Unit
resetButtonEventListener _ = do
  runAff_ genericErrorsHandlerEither callReset
