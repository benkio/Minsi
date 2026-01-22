module Handlers.Handlers where

import Handers.YoutubeVideo.Handler (setVideoHandlers)
import Prelude
import Effect (Effect)
import Data.Tuple (Tuple(..))
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Web.DOM.Element (toEventTarget)
import Web.HTML.HTMLInputElement as HI

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers (Tuple (HtmlInputs { cutStart, cutEnd, youtubeUrl }) (HtmlOutputs { playbackPosition })) = do
  -- handlers for the cut start and cut end buttons to get the current positions and set the values of the sliders
  setVideoHandlers cutStart playbackPosition cutEnd ytUrlEventTarget
  where
  ytUrlEventTarget = (toEventTarget (HI.toElement youtubeUrl))
