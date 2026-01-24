module Handlers.Handlers where

import Handlers.ApplyButtonHandler (setApplyButtonHandler)
import Handlers.CutRangeHandler (CutRangeTargets(..), setCutRangeHandlers)
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Effect (Effect)
import Handers.YoutubeVideo.YoutubeVideoHandler (setVideoHandlers, VideoEventTargets(..))
import Prelude

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers { htmlInputs: HtmlInputs { cutStart, cutEnd, youtubeUrl, setCutStartButton, setCutEndButton, applyButton }, htmlOutputs: HtmlOutputs { playbackPosition, cutEndValue, cutStartValue } } = do
  setCutRangeHandlers (CRET {cutStart:cutStart, cutEnd:cutEnd, cutEndValue: cutEndValue, cutStartValue:cutStartValue})
  setVideoHandlers (VET { cutStart: cutStart, cutEnd: cutEnd, playbackPosition: playbackPosition, setCutStartButton: setCutStartButton, setCutEndButton: setCutEndButton, youtubeUrl: youtubeUrl, cutStartValue: cutStartValue, cutEndValue: cutEndValue })
  setApplyButtonHandler applyButton

