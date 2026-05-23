module Handlers.ClipboardOutputModalCopyClipboardButtonHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_clipboardOutputModalContent, _clipboardOutputModalCopyClipboardButton)
import Data.Either (either)
import Data.Lens (view)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Aff (Aff, attempt, runAff_)
import Effect.Class (liftEffect)
import Effect.Exception (message)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Promise.Aff (toAffE)
import Web.Clipboard (clipboard, writeText, Clipboard)
import Web.DOM.Element (toEventTarget)
import Web.DOM.Node (textContent)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLPreElement (HTMLPreElement)
import Web.HTML.HTMLPreElement as HP
import Web.HTML.Window (navigator)

setClipboardOutputModalCopyClipboardButtonHandler :: Effect Unit
setClipboardOutputModalCopyClipboardButtonHandler = do
  components <- loadComponents
  let
    button = view _clipboardOutputModalCopyClipboardButton components
    contentEl = view _clipboardOutputModalContent components
  evL <- eventListener (clipboardOutputModalCopyButtonEventListener contentEl)
  addEventListener E.click evL false (toEventTarget (HB.toElement button))

clipboardOutputModalCopyButtonEventListener :: HTMLPreElement -> Event -> Effect Unit
clipboardOutputModalCopyButtonEventListener contentEl _ = genericErrorsHandler do
  body <- textContent (HP.toNode contentEl)
  w <- window
  nav <- navigator w
  maybeClip <- clipboard nav
  maybe
    (throwMinsiError (ClipboardUnavailable "The Clipboard API is not available (unsupported browser or non-secure context)."))
    (\cb -> runAff_ genericErrorsHandlerEither (copyModalContentToClipboardAff cb body))
    maybeClip

copyModalContentToClipboardAff :: Clipboard -> String -> Aff Unit
copyModalContentToClipboardAff cb body = do
  eResult <- attempt $ toAffE (writeText body cb)
  either
    ( \err ->
        liftEffect $ throwMinsiError
          (ClipboardUnavailable ("Could not copy to clipboard: " <> message err))
    )
    (const (pure unit))
    eResult
