module Handlers.GenericModalCopyClipboardButtonHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_genericModalContent, _genericModalContentCopyClipboardButton)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Web.DOM.Element (toEventTarget)
import Web.DOM.Node (textContent)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLPreElement (HTMLPreElement)
import Web.HTML.HTMLPreElement as HP

setGenericModalCopyClipboardButtonHandler :: Effect Unit
setGenericModalCopyClipboardButtonHandler = do
  components <- loadComponents
  let
    button = view _genericModalContentCopyClipboardButton components
    contentEl = view _genericModalContent components
  evL <- eventListener (genericModalCopyClipboardButtonEventListener contentEl)
  addEventListener E.click evL false (toEventTarget (HB.toElement button))

genericModalCopyClipboardButtonEventListener :: HTMLPreElement -> Event -> Effect Unit
genericModalCopyClipboardButtonEventListener contentEl _ = do
  body <- textContent (HP.toNode contentEl)
  log body
