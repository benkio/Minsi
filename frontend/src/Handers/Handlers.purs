module Handlers.Handlers where

import Handers.YoutubeVideo.Handler (setVideoHandlers)

import Handers.YoutubeVideo.Handler (youtubeUrlEventListener)

import Prelude
import Effect (Effect)
import Data.Tuple (Tuple(..))
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.DOM.Element (toEventTarget)
import Web.HTML.HTMLInputElement as HI

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers (Tuple (HtmlInputs { youtubeUrl }) (HtmlOutputs _)) = do
  setVideoHandlers ytUrlEventTarget
  where
  ytUrlEventTarget = (toEventTarget (HI.toElement youtubeUrl))
