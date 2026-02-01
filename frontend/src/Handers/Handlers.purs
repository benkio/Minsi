module Handlers.Handlers where

import Handlers.AddSubtitleButtonHandler (setAddSubtitleButtonHandler)
import Handlers.ApplyButtonHandler (setApplyButtonHandler)
import Handlers.CutRangeHandler (CutRangeTargets(..), setCutRangeHandlers)
import Handlers.KeyboardHandler (KeyboardHandlerTargets(..), setKeyboardHandlers)
import Handlers.RemoveSubtitleButtonHandler (setRemoveSubtitleButtonHandler)
import Handlers.ResultVideo.Handler (ResultVideoEventTargets(..), setResultVideoHandlers)
import Handlers.SubtitleTimeButtonsHandler (SubtitleTimeButtonsTargets(..), setSubtitleTimeButtonsHandlers)
import Handlers.VideoSourceHandler (setVideoSourceHandler)
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Components.HtmlIds (keyboardShortcutsModalId)
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
      , subtitleRow
      , addSubtitleButton
      , setSubtitleStartButton
      , setSubtitleEndButton
      }
  , htmlOutputs: HtmlOutputs
      { playbackPositionYoutube
      , playbackPositionResultVideo
      , cutEndValue
      , cutStartValue
      , resultVideo
      , keyboardShortcutsButton
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
  setResultVideoHandlers ( RVET {
                             playbackPositionResultVideo: playbackPositionResultVideo,
                             resultVideo: resultVideo
                             })
  setApplyButtonHandler applyButton
  setKeyboardHandlers (KHT {
    cutStart,
    cutEnd,
    cutStartValue,
    cutEndValue,
    subtitleTable,
    subtitleRow,
    resultVideo,
    keyboardShortcutsModalId,
    keyboardShortcutsButton
  })
  setAddSubtitleButtonHandler addSubtitleButton subtitleTable subtitleRow
  setRemoveSubtitleButtonHandler subtitleTable
  setSubtitleTimeButtonsHandlers (STBT {
    setSubtitleStartButton: setSubtitleStartButton
    , setSubtitleEndButton: setSubtitleEndButton
    , subtitleTable: subtitleTable
    , resultVideo: resultVideo
  })
  setVideoSourceHandler videoSource resultVideo
