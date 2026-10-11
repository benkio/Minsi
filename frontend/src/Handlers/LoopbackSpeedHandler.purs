module Handlers.LoopbackSpeedHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_loopbackSpeed, _uploadLocalFile)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLInputElement as HI

setLoopbackSpeedHandler :: Effect Unit
setLoopbackSpeedHandler = genericErrorsHandler $ do
  components <- loadComponents
  let
    loopbackSpeed = view _loopbackSpeed components
    uploadLocalFile = view _uploadLocalFile components
  loopbackSpeedEvL <- eventListener (loopbackSpeedListener uploadLocalFile)
  addEventListener E.input loopbackSpeedEvL false (toEventTarget (HI.toElement loopbackSpeed))
  addEventListener E.change loopbackSpeedEvL false (toEventTarget (HI.toElement loopbackSpeed))
  pure unit

loopbackSpeedListener :: HI.HTMLInputElement -> Event -> Effect Unit
loopbackSpeedListener uploadLocalFile _ =
  log "[LoopbackSpeedHandler] set the uploadLocalFile to true"
    *> HI.setChecked true uploadLocalFile
