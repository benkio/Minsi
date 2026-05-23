module Handlers.ImportStateButtonHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_importStateButton, _importStateModalTextarea)
import Components.HtmlIdAndClasses (importStateModalId)
import Components.Modal (showModal)
import Data.Lens (view)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLTextAreaElement as HTA

setImportStateButtonHandler :: Effect Unit
setImportStateButtonHandler = do
  components <- loadComponents
  let importStateButton = view _importStateButton components
  evL <- eventListener importStateButtonEventListener
  addEventListener E.click evL false (toEventTarget (HB.toElement importStateButton))

importStateButtonEventListener :: Event -> Effect Unit
importStateButtonEventListener _ =
  genericErrorsHandler do
    components <- loadComponents
    let textarea = view _importStateModalTextarea components
    HTA.setValue "" textarea
    showModal importStateModalId false
