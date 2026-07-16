module Components.HtmlComponents.Lenses
  ( -- HtmlComponents — top-level record props
    _htmlInputs
  , _htmlOutputs
  , _htmlVisualElements
  -- Newtype unwrapping (compose with prop for inner fields)
  , _HtmlInputs
  , _HtmlOutputs
  , _ClipboardOutputModal
  , _ImportStateModal
  , _HtmlVisualElementsFields
  -- HtmlComponents → HtmlInputs fields
  , _cutStart
  , _cutEnd
  , _shiftVideoSync
  , _youtubeUrl
  , _downloadFullButton
  , _localFile
  , _uploadLocalFile
  , _filename
  , _reverseLoop
  , _artist
  , _title
  , _applyButton
  , _videoSource
  , _inputSource
  , _downloadAllButton
  , _copyTranscriptButton
  , _exportStateButton
  , _importStateButton
  , _importStateModalImportButton
  , _setCutEndButton
  , _setCutStartButton
  , _subtitleTable
  , _addSubtitleButton
  , _sortSubtitlesButton
  , _setSubtitleStartButton
  , _setSubtitleEndButton
  , _subtitleRowTemplate
  , _keyboardShortcutsButton
  , _resetButton
  -- HtmlComponents → HtmlOutputs fields
  , _resultPreview
  , _minsiLog
  , _minsiLogTitle
  , _playbackPositionYoutube
  , _playbackPositionResultMedia
  , _loadingModal
  , _loadingModalExtraContent
  , _minsiErrorModal
  , _clipboardOutputModal
  , _clipboardOutputModalContent
  , _clipboardOutputModalCopyClipboardButton
  , _importStateModal
  , _importStateModalTitle
  , _importStateModalTextarea
  , _resultVideo
  , _resultAudio
  -- HtmlComponents → HtmlVisualElements fields
  , _videoSourceRow
  , _videoRow
  , _subtitlesRow
  , _playbackPositionResultRow
  , _minsiLogBox
  -- ResultPreview
  , _ResultPreviewVideo
  , _ResultPreviewIframe
  ) where

import Prelude

import Components.HtmlComponents (ClipboardOutputModal(..), HtmlComponents, HtmlInputs(..), HtmlOutputs(..), HtmlVisualElements(..), ImportStateModal(..), ResultPreview(..))
import Data.Lens (Lens')
import Data.Lens.Iso (Iso', iso)
import Data.Lens.Iso.Newtype (unto)
import Data.Lens.Prism (Prism', prism')
import Data.Lens.Record (prop)
import Data.Maybe (Maybe(..))
import Type.Proxy (Proxy(..))
import Web.DOM.HTMLCollection (HTMLCollection)
import Web.HTML.HTMLAudioElement (HTMLAudioElement)
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Web.HTML.HTMLDivElement (HTMLDivElement)
import Web.HTML.HTMLHeadingElement (HTMLHeadingElement)
import Web.HTML.HTMLIFrameElement (HTMLIFrameElement)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLParagraphElement (HTMLParagraphElement)
import Web.HTML.HTMLPreElement (HTMLPreElement)
import Web.HTML.HTMLSelectElement (HTMLSelectElement)
import Web.HTML.HTMLSpanElement (HTMLSpanElement)
import Web.HTML.HTMLTableElement (HTMLTableElement)
import Web.HTML.HTMLTemplateElement (HTMLTemplateElement)
import Web.HTML.HTMLTextAreaElement (HTMLTextAreaElement)
import Web.HTML.HTMLVideoElement (HTMLVideoElement)

-- Top-level HtmlComponents ---------------------------------------------------

_htmlInputs :: Lens' HtmlComponents HtmlInputs
_htmlInputs = prop (Proxy :: Proxy "htmlInputs")

_htmlOutputs :: Lens' HtmlComponents HtmlOutputs
_htmlOutputs = prop (Proxy :: Proxy "htmlOutputs")

_htmlVisualElements :: Lens' HtmlComponents HtmlVisualElements
_htmlVisualElements = prop (Proxy :: Proxy "htmlVisualElements")

-- Newtype isos to the inner records ---------------------------------------------------

_HtmlInputs
  :: Iso' HtmlInputs
       { cutStart :: HTMLInputElement
       , cutEnd :: HTMLInputElement
       , shiftVideoSync :: HTMLInputElement
       , youtubeUrl :: HTMLInputElement
       , downloadFullButton :: HTMLButtonElement
       , localFile :: HTMLInputElement
       , uploadLocalFile :: HTMLInputElement
       , filename :: HTMLInputElement
       , reverseLoop :: HTMLInputElement
       , artist :: HTMLInputElement
       , title :: HTMLInputElement
       , applyButton :: HTMLButtonElement
       , videoSource :: HTMLSelectElement
       , inputSource :: HTMLSelectElement
       , downloadAllButton :: HTMLButtonElement
       , copyTranscriptButton :: HTMLButtonElement
       , exportStateButton :: HTMLButtonElement
       , importStateButton :: HTMLButtonElement
       , setCutEndButton :: HTMLButtonElement
       , setCutStartButton :: HTMLButtonElement
       , subtitleTable :: HTMLTableElement
       , addSubtitleButton :: HTMLButtonElement
       , sortSubtitlesButton :: HTMLButtonElement
       , setSubtitleStartButton :: HTMLButtonElement
       , setSubtitleEndButton :: HTMLButtonElement
       , subtitleRow :: HTMLTemplateElement
       , keyboardShortcutsButton :: HTMLButtonElement
       , resetButton :: HTMLButtonElement
       , importStateModalImportButton :: HTMLButtonElement
       }
_HtmlInputs = unto HtmlInputs

_HtmlOutputs
  :: Iso' HtmlOutputs
       { resultPreview :: ResultPreview
       , minsiLog :: HTMLDivElement
       , minsiLogTitle :: HTMLDivElement
       , playbackPositionYoutube :: HTMLParagraphElement
       , playbackPositionResultMedia :: HTMLParagraphElement
       , loadingModal :: HTMLDivElement
       , loadingModalExtraContent :: HTMLSpanElement
       , minsiErrorModal :: HTMLDivElement
       , clipboardOutputModal :: ClipboardOutputModal
       , importStateModal :: ImportStateModal
       , resultVideo :: HTMLVideoElement
       , resultAudio :: HTMLAudioElement
       }
_HtmlOutputs = unto HtmlOutputs

_ClipboardOutputModal
  :: Iso' ClipboardOutputModal
       { modal :: HTMLDivElement
       , title :: HTMLHeadingElement
       , content :: HTMLPreElement
       , contentCopyClipboardButton :: HTMLButtonElement
       }
_ClipboardOutputModal = unto ClipboardOutputModal

_ImportStateModal
  :: Iso' ImportStateModal
       { modal :: HTMLDivElement
       , title :: HTMLHeadingElement
       , textarea :: HTMLTextAreaElement
       }
_ImportStateModal = unto ImportStateModal

_HtmlVisualElementsFields
  :: Iso' HtmlVisualElements
       { videoSourceRow :: HTMLDivElement
       , videoRow :: HTMLDivElement
       , subtitlesRow :: HTMLDivElement
       , playbackPositionResultRow :: HTMLDivElement
       , minsiLogBox :: HTMLCollection
       }
_HtmlVisualElementsFields = iso (\(HtmlVisualElements r) -> r) HtmlVisualElements

-- HtmlInputs (template element: _subtitleRowTemplate — record label is still `subtitleRow`)

_cutStart :: Lens' HtmlComponents HTMLInputElement
_cutStart = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "cutStart")

_cutEnd :: Lens' HtmlComponents HTMLInputElement
_cutEnd = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "cutEnd")

_shiftVideoSync :: Lens' HtmlComponents HTMLInputElement
_shiftVideoSync = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "shiftVideoSync")

_youtubeUrl :: Lens' HtmlComponents HTMLInputElement
_youtubeUrl = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "youtubeUrl")

_downloadFullButton :: Lens' HtmlComponents HTMLButtonElement
_downloadFullButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "downloadFullButton")

_localFile :: Lens' HtmlComponents HTMLInputElement
_localFile = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "localFile")

_uploadLocalFile :: Lens' HtmlComponents HTMLInputElement
_uploadLocalFile = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "uploadLocalFile")

_filename :: Lens' HtmlComponents HTMLInputElement
_filename = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "filename")

_reverseLoop :: Lens' HtmlComponents HTMLInputElement
_reverseLoop = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "reverseLoop")

_artist :: Lens' HtmlComponents HTMLInputElement
_artist = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "artist")

_title :: Lens' HtmlComponents HTMLInputElement
_title = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "title")

_applyButton :: Lens' HtmlComponents HTMLButtonElement
_applyButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "applyButton")

_videoSource :: Lens' HtmlComponents HTMLSelectElement
_videoSource = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "videoSource")

_inputSource :: Lens' HtmlComponents HTMLSelectElement
_inputSource = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "inputSource")

_downloadAllButton :: Lens' HtmlComponents HTMLButtonElement
_downloadAllButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "downloadAllButton")

_copyTranscriptButton :: Lens' HtmlComponents HTMLButtonElement
_copyTranscriptButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "copyTranscriptButton")

_exportStateButton :: Lens' HtmlComponents HTMLButtonElement
_exportStateButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "exportStateButton")

_importStateButton :: Lens' HtmlComponents HTMLButtonElement
_importStateButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "importStateButton")

_importStateModalImportButton :: Lens' HtmlComponents HTMLButtonElement
_importStateModalImportButton =
  _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "importStateModalImportButton")

_setCutEndButton :: Lens' HtmlComponents HTMLButtonElement
_setCutEndButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "setCutEndButton")

_setCutStartButton :: Lens' HtmlComponents HTMLButtonElement
_setCutStartButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "setCutStartButton")

_subtitleTable :: Lens' HtmlComponents HTMLTableElement
_subtitleTable = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "subtitleTable")

_addSubtitleButton :: Lens' HtmlComponents HTMLButtonElement
_addSubtitleButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "addSubtitleButton")

_sortSubtitlesButton :: Lens' HtmlComponents HTMLButtonElement
_sortSubtitlesButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "sortSubtitlesButton")

_setSubtitleStartButton :: Lens' HtmlComponents HTMLButtonElement
_setSubtitleStartButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "setSubtitleStartButton")

_setSubtitleEndButton :: Lens' HtmlComponents HTMLButtonElement
_setSubtitleEndButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "setSubtitleEndButton")

_subtitleRowTemplate :: Lens' HtmlComponents HTMLTemplateElement
_subtitleRowTemplate = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "subtitleRow")

_keyboardShortcutsButton :: Lens' HtmlComponents HTMLButtonElement
_keyboardShortcutsButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "keyboardShortcutsButton")

_resetButton :: Lens' HtmlComponents HTMLButtonElement
_resetButton = _htmlInputs <<< unto HtmlInputs <<< prop (Proxy :: Proxy "resetButton")

-- HtmlOutputs ----------------------------------------------------------------

_resultPreview :: Lens' HtmlComponents ResultPreview
_resultPreview = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "resultPreview")

_minsiLog :: Lens' HtmlComponents HTMLDivElement
_minsiLog = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "minsiLog")

_minsiLogTitle :: Lens' HtmlComponents HTMLDivElement
_minsiLogTitle = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "minsiLogTitle")

_playbackPositionYoutube :: Lens' HtmlComponents HTMLParagraphElement
_playbackPositionYoutube = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "playbackPositionYoutube")

_playbackPositionResultMedia :: Lens' HtmlComponents HTMLParagraphElement
_playbackPositionResultMedia = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "playbackPositionResultMedia")

_loadingModal :: Lens' HtmlComponents HTMLDivElement
_loadingModal = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "loadingModal")

_loadingModalExtraContent :: Lens' HtmlComponents HTMLSpanElement
_loadingModalExtraContent = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "loadingModalExtraContent")

_minsiErrorModal :: Lens' HtmlComponents HTMLDivElement
_minsiErrorModal = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "minsiErrorModal")

_clipboardOutputModal :: Lens' HtmlComponents ClipboardOutputModal
_clipboardOutputModal =
  _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "clipboardOutputModal")

_clipboardOutputModalContent :: Lens' HtmlComponents HTMLPreElement
_clipboardOutputModalContent =
  _clipboardOutputModal <<< _ClipboardOutputModal <<< prop (Proxy :: Proxy "content")

_clipboardOutputModalCopyClipboardButton :: Lens' HtmlComponents HTMLButtonElement
_clipboardOutputModalCopyClipboardButton =
  _clipboardOutputModal
    <<< _ClipboardOutputModal
    <<< prop (Proxy :: Proxy "contentCopyClipboardButton")

_importStateModal :: Lens' HtmlComponents ImportStateModal
_importStateModal = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "importStateModal")

_importStateModalTitle :: Lens' HtmlComponents HTMLHeadingElement
_importStateModalTitle =
  _importStateModal <<< _ImportStateModal <<< prop (Proxy :: Proxy "title")

_importStateModalTextarea :: Lens' HtmlComponents HTMLTextAreaElement
_importStateModalTextarea =
  _importStateModal <<< _ImportStateModal <<< prop (Proxy :: Proxy "textarea")

_resultVideo :: Lens' HtmlComponents HTMLVideoElement
_resultVideo = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "resultVideo")

_resultAudio :: Lens' HtmlComponents HTMLAudioElement
_resultAudio = _htmlOutputs <<< unto HtmlOutputs <<< prop (Proxy :: Proxy "resultAudio")

-- HtmlVisualElements ---------------------------------------------------------

_videoSourceRow :: Lens' HtmlComponents HTMLDivElement
_videoSourceRow = _htmlVisualElements <<< _HtmlVisualElementsFields <<< prop (Proxy :: Proxy "videoSourceRow")

_videoRow :: Lens' HtmlComponents HTMLDivElement
_videoRow = _htmlVisualElements <<< _HtmlVisualElementsFields <<< prop (Proxy :: Proxy "videoRow")

_subtitlesRow :: Lens' HtmlComponents HTMLDivElement
_subtitlesRow = _htmlVisualElements <<< _HtmlVisualElementsFields <<< prop (Proxy :: Proxy "subtitlesRow")

_playbackPositionResultRow :: Lens' HtmlComponents HTMLDivElement
_playbackPositionResultRow = _htmlVisualElements <<< _HtmlVisualElementsFields <<< prop (Proxy :: Proxy "playbackPositionResultRow")

_minsiLogBox :: Lens' HtmlComponents HTMLCollection
_minsiLogBox = _htmlVisualElements <<< _HtmlVisualElementsFields <<< prop (Proxy :: Proxy "minsiLogBox")

-- ResultPreview -----------------------------------------------------------------------

_ResultPreviewVideo :: Prism' ResultPreview HTMLVideoElement
_ResultPreviewVideo = prism' ResultPreviewVideo case _ of
  ResultPreviewVideo v -> Just v
  _ -> Nothing

_ResultPreviewIframe :: Prism' ResultPreview HTMLIFrameElement
_ResultPreviewIframe = prism' ResultPreviewIframe case _ of
  ResultPreviewIframe i -> Just i
  _ -> Nothing
