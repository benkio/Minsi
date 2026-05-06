module Handlers.ExportStateButtonHandler where

import Prelude

import Handlers.ErrorHandlers (genericErrorsHandler)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_exportStateButton, _genericModalContent)
import Components.HtmlIdAndClasses (genericModalId)
import Components.Modal (showModal)
import Data.Lens (view)
import Data.Tuple (fst, snd)
import Effect (Effect)
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.DOM.Node (setTextContent)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLPreElement as HP
import Yoga.JSON (writeJSON)

setExportStateButtonHandler :: Effect Unit
setExportStateButtonHandler = do
  components <- loadComponents
  let exportStateButton = view _exportStateButton components
  evL <- eventListener exportStateButtonEventListener
  addEventListener E.click evL false (toEventTarget (HB.toElement exportStateButton))

exportStateButtonEventListener :: Event -> Effect Unit
exportStateButtonEventListener _ = genericErrorsHandler $ do
  stateTuple <- getCurrentState
  let
    stateJson = writeJSON (fst stateTuple)
    genericModalContentEl = view _genericModalContent (snd stateTuple)
  setTextContent stateJson (HP.toNode genericModalContentEl)
  showModal genericModalId true
