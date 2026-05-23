module Handlers.ImportStateModalImportButtonHandler where

import Prelude

import Data.String.CodeUnits (length)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_importStateModalImportButton, _importStateModalTextarea)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLTextAreaElement as HTA

setImportStateModalImportButtonHandler :: Effect Unit
setImportStateModalImportButtonHandler = do
  components <- loadComponents
  let
    button = view _importStateModalImportButton components
    textarea = view _importStateModalTextarea components
  evL <- eventListener (importStateModalImportClick textarea)
  addEventListener E.click evL false (toEventTarget (HB.toElement button))

importStateModalImportClick :: HTA.HTMLTextAreaElement -> Event -> Effect Unit
importStateModalImportClick textarea _ =
  genericErrorsHandler do
    jsonText <- HTA.value textarea
    log $ "[ImportStateModal] Import state clicked; payload length=" <> show (length jsonText)
