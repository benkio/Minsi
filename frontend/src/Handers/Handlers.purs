module Handlers.Handlers where

import Data.Traversable (traverse)

import Data.Maybe (Maybe)

import Prelude
import Effect (Effect)
import Data.Tuple (Tuple(..))
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.DOM.Element (toEventTarget, fromEventTarget)
import Web.HTML.Event.EventTypes as E
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI
import Web.Event.Event (target)
import Effect.Console (log)

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers (Tuple (HtmlInputs { youtubeUrl }) (HtmlOutputs _)) = do
  ytEvL <- eventListener youtubeUrlEventListener
  addEventListener E.change ytEvL false (toEventTarget (HI.toElement youtubeUrl))

youtubeUrlEventListener :: Event -> Effect Unit
youtubeUrlEventListener ev = do
    value <- getInputValue ev
    log ("Youtube Url Handler fired with value: " <> show value)

getInputValue :: Event -> Effect (Maybe String)
getInputValue ev =
  traverse (HI.value) (target ev >>= fromEventTarget >>= HI.fromElement)
