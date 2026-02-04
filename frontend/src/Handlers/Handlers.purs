module Handlers.Handlers where

import Handlers.ApplyButtonHandler (setApplyButtonHandler)
import Handlers.CutRangeHandler (CutRangeTargets(..), setCutRangeHandlers)
import Handlers.CopyTranscriptButtonHandler (setCopyTranscriptButtonHandler)
import Handlers.DownloadAllButtonHandler (setDownloadAllButtonHandler)
import Handlers.DownloadButtonHandler (setDownloadButtonHandler)
import Handlers.KeyboardHandler (KeyboardHandlerTargets(..), setKeyboardHandlers)
import Handlers.ResultVideo.Handler (ResultVideoEventTargets(..), setResultVideoHandlers)
import Handlers.ResultVideo.VideoSourceHandler (setVideoSourceHandler)
import Handlers.Subtitles.AddSubtitleButtonHandler (setAddSubtitleButtonHandler)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (setRemoveSubtitleButtonHandler)
import Handlers.Subtitles.SubtitleTimeButtonsHandler (SubtitleTimeButtonsTargets(..), setSubtitleTimeButtonsHandlers)
import Handlers.TextInputValidationHandler (TextInputValidationTargets(..), setTextInputValidationHandlers)
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Components.HtmlIds (keyboardShortcutsModalId)
import Effect (Effect)
import Handlers.YoutubeVideo.YoutubeVideoHandler (setVideoHandlers, VideoEventTargets(..))
import Prelude

--TODO: Handlers here get too much parameters
-- the idea is to set the handler with the given target
-- then inside the element itself, compute the current state and get the extra elements from there.
setupEventHandlers :: HtmlComponents -> Effect Unit
setupEventHandlers
  { htmlInputs: HtmlInputs
      { cutStart
      , cutEnd
      , youtubeUrl
      , filename
      , setCutStartButton
      , setCutEndButton
      , applyButton
      , videoSource
      , downloadButton
      , downloadAllButton
      , copyTranscriptButton
      , subtitleTable
      , subtitleRow
      , addSubtitleButton
      , setSubtitleStartButton
      , setSubtitleEndButton
      , artist
      , title
      }
  , htmlOutputs: HtmlOutputs
      { playbackPositionYoutube
      , playbackPositionResultVideo
      , cutEndValue
      , cutStartValue
      , resultVideo
      , resultAudio
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
  setResultVideoHandlers
    ( RVET
        { playbackPositionResultVideo: playbackPositionResultVideo
        , resultVideo: resultVideo
        }
    )
  setApplyButtonHandler applyButton
  setKeyboardHandlers
    ( KHT
        { cutStart
        , cutEnd
        , cutStartValue
        , cutEndValue
        , subtitleTable
        , subtitleRow
        , resultVideo
        , keyboardShortcutsModalId
        , keyboardShortcutsButton
        }
    )
  setAddSubtitleButtonHandler addSubtitleButton subtitleTable subtitleRow
  setRemoveSubtitleButtonHandler subtitleTable
  setSubtitleTimeButtonsHandlers
    ( STBT
        { setSubtitleStartButton: setSubtitleStartButton
        , setSubtitleEndButton: setSubtitleEndButton
        , subtitleTable: subtitleTable
        , resultVideo: resultVideo
        }
    )
  setVideoSourceHandler videoSource resultVideo resultAudio
  setDownloadButtonHandler downloadButton videoSource
  setDownloadAllButtonHandler downloadAllButton
  setCopyTranscriptButtonHandler copyTranscriptButton
  setTextInputValidationHandlers
    ( TIVT
        { outputFilename: filename
        , artist
        , title
        }
    )
