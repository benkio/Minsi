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
import Effect.Console (log)

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers (Tuple (HtmlInputs { youtubeUrl }) (HtmlOutputs _)) = do
  ytEvL <- eventListener youtubeUrlEventListener
  -- Add both 'change' (fires on blur) and 'input' (fires while typing) events
  -- 'input' is more responsive, but 'change' is also useful
  addEventListener E.input ytEvL false (toEventTarget (HI.toElement youtubeUrl))
  addEventListener E.change ytEvL false (toEventTarget (HI.toElement youtubeUrl))
  log "YouTube URL event listeners attached (input and change)"
