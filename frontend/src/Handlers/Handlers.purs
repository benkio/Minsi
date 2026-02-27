module Handlers.Handlers where

import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlOutputs(..))
import Components.HtmlIdAndClasses (keyboardShortcutsModalId)
import Effect (Effect)
import Handlers.ApplyButtonHandler (setApplyButtonHandler)
import Handlers.CopyTranscriptButtonHandler (setCopyTranscriptButtonHandler)
import Handlers.CutRangeHandler (CutRangeTargets(..), setCutRangeHandlers)
import Handlers.DownloadAllButtonHandler (setDownloadAllButtonHandler)
import Handlers.InputVideo.InputSourceHandler (setInputSourceHandler)
import Handlers.InputVideo.InputVideoHandler (setVideoHandlers, VideoEventTargets(..))
import Handlers.KeyboardHandler (KeyboardHandlerTargets(..), setKeyboardHandlers)
import Handlers.ResultVideo.Handler (ResultVideoEventTargets(..), setResultVideoHandlers)
import Handlers.ResultVideo.VideoSourceHandler (setVideoSourceHandler)
import Handlers.Subtitles.AddSubtitleButtonHandler (setAddSubtitleButtonHandler)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (setRemoveSubtitleButtonHandler)
import Handlers.Subtitles.SubtitleTimeButtonsHandler (SubtitleTimeButtonsTargets(..), setSubtitleTimeButtonsHandlers)
import Handlers.TextInputValidationHandler (TextInputValidationTargets(..), setTextInputValidationHandlers)
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
      , localFile
      , uploadLocalFile
      , filename
      , setCutStartButton
      , setCutEndButton
      , applyButton
      , videoSource
      , inputSource
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
      , resultVideo
      , resultAudio
      , keyboardShortcutsButton
      }
  } = do
  setCutRangeHandlers
    ( CRET
        { cutStart: cutStart
        , cutEnd: cutEnd
        , uploadLocalFile: uploadLocalFile
        }
    )
  setVideoHandlers
    ( VET
        { playbackPositionYoutube: playbackPositionYoutube
        , setCutStartButton: setCutStartButton
        , setCutEndButton: setCutEndButton
        , youtubeUrl: youtubeUrl
        , localFile: localFile
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
  setInputSourceHandler inputSource youtubeUrl localFile
  setDownloadAllButtonHandler downloadAllButton
  setCopyTranscriptButtonHandler copyTranscriptButton
  setTextInputValidationHandlers
    ( TIVT
        { outputFilename: filename
        , artist
        , title
        }
    )
