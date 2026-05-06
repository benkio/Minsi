module Handlers.GenericModalCopyClipboardButtonHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_genericModalContent, _genericModalContentCopyClipboardButton)
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

setGenericModalCopyClipboardButtonHandler :: Effect Unit
setGenericModalCopyClipboardButtonHandler = do
  components <- loadComponents
  let
    button = view _genericModalContentCopyClipboardButton components
    contentEl = view _genericModalContent components
  evL <- eventListener (genericModalCopyClipboardButtonEventListener contentEl)
  addEventListener E.click evL false (toEventTarget (HB.toElement button))

genericModalCopyClipboardButtonEventListener :: HTMLPreElement -> Event -> Effect Unit
genericModalCopyClipboardButtonEventListener contentEl _ = genericErrorsHandler do
  body <- textContent (HP.toNode contentEl)
  w <- window
  nav <- navigator w
  maybeClip <- clipboard nav
  maybe
    (throwMinsiError (ClipboardUnavailable "The Clipboard API is not available (unsupported browser or non-secure context)."))
    (\clipboard -> runAff_ genericErrorsHandlerEither (copyModalContentToClipboardAff clipboard body))
    maybeClip

copyModalContentToClipboardAff :: Clipboard -> String -> Aff Unit
copyModalContentToClipboardAff clipboard body = do
  eResult <- attempt $ toAffE (writeText body clipboard)
  either
    ( \err ->
        liftEffect $ throwMinsiError
          (ClipboardUnavailable ("Could not copy to clipboard: " <> message err))
    )
    (const (pure unit))
    eResult
