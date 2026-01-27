module Handlers.Handlers where

import Handlers.AddSubtitleButtonHandler (setAddSubtitleButtonHandler)
import Handlers.ApplyButtonHandler (setApplyButtonHandler)
import Handlers.CutRangeHandler (CutRangeTargets(..), setCutRangeHandlers)
import Handlers.KeyboardHandler (setKeyboardHandlers)
import Handlers.VideoSourceHandler (setVideoSourceHandler)
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Effect (Effect)
import Handers.YoutubeVideo.YoutubeVideoHandler (setVideoHandlers, VideoEventTargets(..))
import Prelude

setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers
  { htmlInputs: HtmlInputs
      { cutStart
      , cutEnd
      , youtubeUrl
      , setCutStartButton
      , setCutEndButton
      , applyButton
      , videoSource
      , subtitleTable
      }
  , htmlOutputs: HtmlOutputs
      { playbackPositionYoutube
      , playbackPositionResultVideo
      , cutEndValue
      , cutStartValue
      , addSubtitleButton
      , resultVideo
      }
  } = do
  setCutRangeHandlers
    ( CRET
        { cutStart: cutStart
        , cutEnd: cutEnd
        , cutEndValue: cutEndValue
        , cutStartValue: cutStartValue
        }
    )
  setVideoHandlers
    ( VET
        { cutStart: cutStart
        , cutEnd: cutEnd
        , playbackPositionYoutube: playbackPositionYoutube
        , setCutStartButton: setCutStartButton
        , setCutEndButton: setCutEndButton
        , youtubeUrl: youtubeUrl
        , cutStartValue: cutStartValue
        , cutEndValue: cutEndValue
        }
    )
  setApplyButtonHandler applyButton
  setKeyboardHandlers
  setAddSubtitleButtonHandler addSubtitleButton
  setVideoSourceHandler videoSource resultVideo

