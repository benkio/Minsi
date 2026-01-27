module Handlers.AddSubtitleButtonHandler where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.Event.EventTypes as E

setAddSubtitleButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setAddSubtitleButtonHandler addSubtitleButton = do
  addSubtitleButtonEvL <- eventListener addSubtitleButtonEventListener
  addEventListener E.click addSubtitleButtonEvL false addSubtitleButtonEventTarget
  where
  addSubtitleButtonEventTarget = toEventTarget (HB.toElement addSubtitleButton)

addSubtitleButtonEventListener :: Event -> Effect Unit
addSubtitleButtonEventListener _ = do
  log "Add Subtitle button clicked"
