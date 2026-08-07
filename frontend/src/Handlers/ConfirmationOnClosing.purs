module Handlers.ConfirmationOnClose where

import Prelude (Unit, bind, pure, unit, ($))
import Web.HTML.Event.BeforeUnloadEvent (fromEvent, setReturnValue)

import Data.Maybe (maybe)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.Event.Event (Event)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (window)
import Web.HTML.Event.BeforeUnloadEvent.EventTypes (beforeunload)
import Web.HTML.Window (toEventTarget)

setConfirmationOnClosing :: Effect Unit
setConfirmationOnClosing = genericErrorsHandler $ do
  w <- window
  confirmationOnClosing <- eventListener confirmatinoOnClosingEventListener
  addEventListener beforeunload confirmationOnClosing false (toEventTarget w)

confirmatinoOnClosingEventListener :: Event -> Effect Unit
confirmatinoOnClosingEventListener ev =
  maybe (pure unit) (setReturnValue "Do you want to close the window?") $ fromEvent ev
