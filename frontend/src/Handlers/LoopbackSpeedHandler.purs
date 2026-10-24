module Handlers.LoopbackSpeedHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_loopbackSpeed, _uploadLocalFile)
import Components.HtmlIdAndClasses (loopbackSpeedId)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Validations.Number (valueAsNumber)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLInputElement as HI

loopbackMaxValue :: Number
loopbackMaxValue = 4.0

setLoopbackSpeedHandler :: Effect Unit
setLoopbackSpeedHandler = genericErrorsHandler $ do
  components <- loadComponents
  let
    loopbackSpeed = view _loopbackSpeed components
    uploadLocalFile = view _uploadLocalFile components
  loopbackSpeedEvL <- eventListener (loopbackSpeedListener loopbackSpeed uploadLocalFile)
  addEventListener E.input loopbackSpeedEvL false (toEventTarget (HI.toElement loopbackSpeed))
  addEventListener E.change loopbackSpeedEvL false (toEventTarget (HI.toElement loopbackSpeed))
  pure unit

loopbackSpeedListener :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
loopbackSpeedListener loopbackSpeed uploadLocalFile _ = genericErrorsHandler do
  loopbackValue <- valueAsNumber loopbackSpeedId loopbackSpeed
  when
    (loopbackValue > loopbackMaxValue || loopbackValue < 0.0)
    ( throwMinsiError
        ( InvalidInput
            loopbackSpeedId
            ("[LoopbackSpeedHandler] LoopbackSpeed value out of range (0 - " <> show loopbackMaxValue <> "): " <> show loopbackValue)
        )
    )
  log "[LoopbackSpeedHandler] set the uploadLocalFile to true"
  HI.setChecked true uploadLocalFile
