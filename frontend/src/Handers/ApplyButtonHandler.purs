module Handlers.ApplyButtonHandler where

import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Handers.ErrorHandlers (genericErrorsHandler)
import Effect.Console (log)
import Model.State.StateFromHtml (fromHtmlInputs)
import Data.Validation.Semigroup (toEither)
import Data.Either (Either(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.DOM.Element (toEventTarget)
import Effect (Effect)
import Web.HTML.HTMLButtonElement as HB
import Prelude
import Web.HTML.Event.EventTypes as E
import Web.Event.Internal.Types (Event)
import Components.Window (getDocument)
import Components.HtmlComponents (loadHtmlInputs)

setApplyButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setApplyButtonHandler applyButton = do
  applyButtonEvL <- eventListener applyButtonEventListener
  addEventListener E.click applyButtonEvL false applyButtonEventTarget
  where
    applyButtonEventTarget = toEventTarget (HB.toElement applyButton)

applyButtonEventListener :: Event -> Effect Unit
applyButtonEventListener _ = genericErrorsHandler $ do
  doc <- getDocument
  inputs <- loadHtmlInputs doc
  stateV <- fromHtmlInputs inputs
  case toEither stateV of
    Left errors -> throwMinsiError (InvalidInputs errors)
    Right _ -> log ("State converted")
