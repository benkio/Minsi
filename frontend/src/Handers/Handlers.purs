module Handlers.Handlers where

import Components.HtmlComponents (HtmlComponents, HtmlInputs (..), HtmlOutputs (..))
import Data.Tuple (Tuple (..))
import Effect (Effect)
import Handers.YoutubeVideo.Handler (setVideoHandlers)
import Web.DOM.Element (toEventTarget)
import Web.HTML.HTMLInputElement as HI
import Prelude

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers (Tuple (HtmlInputs{cutStart, cutEnd, youtubeUrl}) (HtmlOutputs{playbackPosition})) = do
    -- TODO: Add handlers for the cut start and cut end buttons to get the current positions and set the values of the sliders
    setVideoHandlers cutStart playbackPosition cutEnd ytUrlEventTarget
    -- TODO: Add Apply Button Handler
  where
    ytUrlEventTarget = (toEventTarget (HI.toElement youtubeUrl))
