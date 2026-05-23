module Handlers.ImportStateModalImportButtonHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_importStateModalImportButton, _importStateModalTextarea)
import Data.Either (Either(..))
import Data.Lens (view)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (State)
import Model.State.StateToHtml (loadCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLTextAreaElement as HTA
import Yoga.JSON (readJSON)

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
    case readJSON jsonText :: Either _ State of
      Left errs ->
        throwMinsiError (JSONParsingError (show errs))
      Right state ->
        loadCurrentState state
