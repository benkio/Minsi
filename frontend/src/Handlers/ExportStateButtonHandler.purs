module Handlers.ExportStateButtonHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_exportStateButton)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB

setExportStateButtonHandler :: Effect Unit
setExportStateButtonHandler = do
  components <- loadComponents
  let exportStateButton = view _exportStateButton components
  evL <- eventListener exportStateButtonEventListener
  addEventListener E.click evL false (toEventTarget (HB.toElement exportStateButton))

exportStateButtonEventListener :: Event -> Effect Unit
exportStateButtonEventListener _ = log "Export state"
