module Handlers.ShiftVideoSyncHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_shiftVideoSync, _uploadLocalFile)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLInputElement as HI

setShiftVideoSyncHandler :: Effect Unit
setShiftVideoSyncHandler = genericErrorsHandler $ do
  components <- loadComponents
  let
    shiftVideoSync = view _shiftVideoSync components
    uploadLocalFile = view _uploadLocalFile components
  shiftVideoSyncEvL <- eventListener (shiftVideoSyncListener uploadLocalFile)
  addEventListener E.input shiftVideoSyncEvL false (toEventTarget (HI.toElement shiftVideoSync))
  addEventListener E.change shiftVideoSyncEvL false (toEventTarget (HI.toElement shiftVideoSync))
  pure unit

shiftVideoSyncListener :: HI.HTMLInputElement -> Event -> Effect Unit
shiftVideoSyncListener uploadLocalFile _ =
  log "[ShiftVideoSyncHandler] set the uploadLocalFile to true"
    *> HI.setChecked true uploadLocalFile
