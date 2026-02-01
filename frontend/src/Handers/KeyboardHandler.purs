module Handlers.KeyboardHandler where

import Prelude
import Effect (Effect)
import Handers.ErrorHandlers (genericErrorsHandler)
import Handlers.ApplyButtonHandler (applyButtonEventListener)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.UIEvent.KeyboardEvent (key, ctrlKey, metaKey, fromEvent)
import Data.Maybe (maybe)
import Web.HTML (window)
import Web.HTML.HTMLDocument as HTMLDocument
import Web.UIEvent.KeyboardEvent.EventTypes as E
import Web.HTML.Window (document)

setKeyboardHandlers :: Effect Unit
setKeyboardHandlers = genericErrorsHandler $ do
  w <- window
  doc <- document w
  keyboardEvL <- eventListener keyboardEventListener
  addEventListener E.keydown keyboardEvL false (HTMLDocument.toEventTarget doc)

keyboardEventListener :: Event -> Effect Unit
keyboardEventListener ev = maybe (pure unit) handleKeyboardEvent (fromEvent ev)
  where
  handleKeyboardEvent keyboardEvent = let
    isCtrl = ctrlKey keyboardEvent
    isMeta = metaKey keyboardEvent
    keyValue = key keyboardEvent
    in when (keyValue == "Enter" && (isCtrl || isMeta)) (applyButtonEventListener ev)
