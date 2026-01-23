module Handlers.ApplyButtonHandler where

import Web.Event.EventTarget (addEventListener, eventListener)
import Web.DOM.Element (toEventTarget)
import Effect (Effect)
import Web.HTML.HTMLButtonElement as HB
import Prelude
import Web.HTML.Event.EventTypes as E
import Web.Event.Internal.Types (Event)

setApplyButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setApplyButtonHandler applyButton = do
  applyButtonEvL <- eventListener applyButtonEventListener
  addEventListener E.click applyButtonEvL false applyButtonEventTarget
  where
    applyButtonEventTarget = toEventTarget (HB.toElement applyButton)

applyButtonEventListener :: Event -> Effect Unit
applyButtonEventListener ev = pure unit 

