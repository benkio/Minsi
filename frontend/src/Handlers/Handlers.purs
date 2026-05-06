module Handlers.Handlers where

import Effect (Effect)
import Handlers.ApplyButtonHandler (setApplyButtonHandler)
import Handlers.CopyTranscriptButtonHandler (setCopyTranscriptButtonHandler)
import Handlers.ExportStateButtonHandler (setExportStateButtonHandler)
import Handlers.CutRangeHandler (setCutRangeHandlers)
import Handlers.DownloadAllButtonHandler (setDownloadAllButtonHandler)
import Handlers.DownloadFullButtonHandler (setDownloadFullButtonHandler)
import Handlers.InputVideo.InputSourceHandler (setInputSourceHandler)
import Handlers.InputVideo.InputVideoHandler (setVideoHandlers)
import Handlers.KeyboardHandler (setKeyboardHandlers)
import Handlers.ResetButtonHandler (setResetButtonHandler)
import Handlers.ResultMedia.Handler (setResultMediaHandlers)
import Handlers.ResultMedia.VideoSourceHandler (setVideoSourceHandler)
import Handlers.Subtitles.AddSubtitleButtonHandler (setAddSubtitleButtonHandler)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (setRemoveSubtitleButtonHandler)
import Handlers.Subtitles.SortSubtitlesButtonHandler (setSortSubtitlesButtonHandler)
import Handlers.Subtitles.SubtitleTimeButtonsHandler (setSubtitleTimeButtonsHandlers)
import Handlers.TextInputValidationHandler (setTextInputValidationHandlers)
import Prelude

setupEventHandlers :: Effect Unit
setupEventHandlers = do
  setCutRangeHandlers
  setVideoHandlers
  setResultMediaHandlers
  setApplyButtonHandler
  setKeyboardHandlers
  setAddSubtitleButtonHandler
  setSortSubtitlesButtonHandler
  setRemoveSubtitleButtonHandler
  setSubtitleTimeButtonsHandlers
  setVideoSourceHandler
  setInputSourceHandler
  setDownloadFullButtonHandler
  setDownloadAllButtonHandler
  setCopyTranscriptButtonHandler
  setExportStateButtonHandler
  setResetButtonHandler
  setTextInputValidationHandlers
