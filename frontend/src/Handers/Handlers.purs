module Handlers.Handlers where

import Handers.YoutubeVideo.Handler (youtubeUrlEventListener)

import Prelude
import Effect (Effect)
import Data.Tuple (Tuple(..))
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.DOM.Element (toEventTarget)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLInputElement as HI

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers (Tuple (HtmlInputs { youtubeUrl }) (HtmlOutputs _)) = do
  ytEvL <- eventListener youtubeUrlEventListener
  addEventListener E.change ytEvL false (toEventTarget (HI.toElement youtubeUrl))
