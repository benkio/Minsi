module Handlers.Handlers where

import Handlers.CutRangeHandler (CutRangeTargets(..), setCutRangeHandlers)
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Handers.YoutubeVideo.YoutubeVideoHandler (setVideoHandlers, VideoEventTargets(..))
import Prelude

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers (Tuple (HtmlInputs { cutStart, cutEnd, youtubeUrl, setCutStartButton, setCutEndButton }) (HtmlOutputs { playbackPosition, cutEndValue, cutStartValue })) = do
  setCutRangeHandlers (CRET {cutStart:cutStart, cutEnd:cutEnd, cutEndValue: cutEndValue, cutStartValue:cutStartValue})
  setVideoHandlers (VET { cutStart: cutStart, cutEnd: cutEnd, playbackPosition: playbackPosition, setCutStartButton: setCutStartButton, setCutEndButton: setCutEndButton, youtubeUrl: youtubeUrl })
  -- TODO: Add Apply Button Handler

