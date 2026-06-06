module Components.HtmlComponents where

import Components.HTMLComponentsLoader (loadHtmlElementClass, loadHtmlElementId)
import Components.HtmlIdAndClasses
  ( addSubtitleId
  , applyId
  , artistId
  , cutEndId
  , cutStartId
  , syncAVId
  , loadingModalId
  , loadingModalExtraConentId
  , minsiErrorModalId
  , clipboardOutputModalCopyClipboardButtonId
  , clipboardOutputModalContentId
  , clipboardOutputModalId
  , clipboardOutputModalTitleId
  , importStateModalId
  , importStateModalImportButtonId
  , importStateModalTextareaId
  , importStateModalTitleId
  , minsiLogId
  , outputFilenameId
  , playbackPositionResultRowId
  , playbackPositionResultMediaId
  , playbackPositionYoutubeId
  , resultPreviewId
  , resultAudioId
  , resultVideoId
  , reverseLoopGifId
  , sortSubtitlesId
  , setCutEndButton
  , setCutStartButton
  , setSubtitleEndButtonId
  , setSubtitleStartButtonId
  , subtitleTableId
  , subtitlesRowId
  , titleId
  , videoRowId
  , videoSourceId
  , inputSourceId
  , videoSourceRowId
  , downloadAllButtonId
  , copyTranscriptButtonId
  , exportStateButtonId
  , importStateButtonId
  , downloadFullButtonId
  , youtubeUrlId
  , subtitleRow
  , keyboardShortcutsButtonId
  , resetButtonId
  , localFileId
  , uploadLocalFileId
  , minsiLogBoxClass
  , minsiLogTitleId
  )
import Components.Window (getDocument)
import Control.Monad.Error.Class (catchError)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Tuple (Tuple(..), fst, snd)
import Effect (Effect)
import Prelude (bind, pure)
import Web.DOM.HTMLCollection (HTMLCollection)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML.HTMLAudioElement (HTMLAudioElement)
import Web.HTML.HTMLAudioElement as HA
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLDivElement (HTMLDivElement)
import Web.HTML.HTMLDivElement as HD
import Web.HTML.HTMLHeadingElement (HTMLHeadingElement)
import Web.HTML.HTMLHeadingElement as HH
import Web.HTML.HTMLIFrameElement (HTMLIFrameElement)
import Web.HTML.HTMLIFrameElement as IF
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement (HTMLSelectElement)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLSpanElement (HTMLSpanElement)
import Web.HTML.HTMLSpanElement as HSP
import Web.HTML.HTMLTableElement (HTMLTableElement)
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTemplateElement (HTMLTemplateElement)
import Web.HTML.HTMLTemplateElement as HTP
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV
import Web.HTML.HTMLPreElement (HTMLPreElement)
import Web.HTML.HTMLPreElement as HP
import Web.HTML.HTMLTextAreaElement (HTMLTextAreaElement)
import Web.HTML.HTMLTextAreaElement as HTA

newtype HtmlInputs = HtmlInputs
  { cutStart :: HTMLInputElement
  , cutEnd :: HTMLInputElement
  , syncAV :: HTMLInputElement
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

data ResultPreview
  = ResultPreviewVideo HTMLVideoElement
  | ResultPreviewIframe HTMLIFrameElement

isResultPreviewIframe :: ResultPreview -> Boolean
isResultPreviewIframe = case _ of
  ResultPreviewIframe _ -> true
  ResultPreviewVideo _ -> false

resultPreviewToMaybeIframe :: ResultPreview -> Maybe HTMLIFrameElement
resultPreviewToMaybeIframe = case _ of
  ResultPreviewIframe iframe -> Just iframe
  ResultPreviewVideo _ -> Nothing

resultPreviewToMaybeVideo :: ResultPreview -> Maybe HTMLVideoElement
resultPreviewToMaybeVideo = case _ of
  ResultPreviewVideo video -> Just video
  ResultPreviewIframe _ -> Nothing

newtype ClipboardOutputModal = ClipboardOutputModal
  { modal :: HTMLDivElement
  , title :: HTMLHeadingElement
  , content :: HTMLPreElement
  , contentCopyClipboardButton :: HTMLButtonElement
  }

derive instance Newtype ClipboardOutputModal _

newtype ImportStateModal = ImportStateModal
  { modal :: HTMLDivElement
  , title :: HTMLHeadingElement
  , textarea :: HTMLTextAreaElement
  }

derive instance Newtype ImportStateModal _

newtype HtmlOutputs = HtmlOutputs
  { resultPreview :: ResultPreview
  , minsiLog :: HTMLDivElement
  , minsiLogTitle :: HTMLDivElement
  , playbackPositionYoutube :: HTMLSpanElement
  , playbackPositionResultMedia :: HTMLSpanElement
  , loadingModal :: HTMLDivElement
  , loadingModalExtraContent :: HTMLSpanElement
  , minsiErrorModal :: HTMLDivElement
  , clipboardOutputModal :: ClipboardOutputModal
  , importStateModal :: ImportStateModal
  , resultVideo :: HTMLVideoElement
  , resultAudio :: HTMLAudioElement
  }

derive instance Newtype HtmlOutputs _
derive instance Newtype HtmlInputs _

data HtmlVisualElements = HtmlVisualElements
  { videoSourceRow :: HTMLDivElement
  , videoRow :: HTMLDivElement
  , subtitlesRow :: HTMLDivElement
  , playbackPositionResultRow :: HTMLDivElement
  , minsiLogBox :: HTMLCollection
  }

type HtmlComponents =
  { htmlInputs :: HtmlInputs
  , htmlOutputs :: HtmlOutputs
  , htmlVisualElements :: HtmlVisualElements
  }

loadComponents :: Effect HtmlComponents
loadComponents = do
  doc <- getDocument
  inputs <- loadHtmlInputs doc
  outputs <- loadHtmlOutputs doc
  visualElements <- loadHtmlVisualElements doc
  pure
    { htmlInputs: inputs
    , htmlOutputs: outputs
    , htmlVisualElements: visualElements
    }

loadHtmlInputs :: NonElementParentNode -> Effect HtmlInputs
loadHtmlInputs doc = do
  rangeTuple <- loadCutRange doc
  syncAV <- loadInput syncAVId doc
  youtubeUrl <- loadInput youtubeUrlId doc
  downloadFullButton <- loadButton downloadFullButtonId doc
  localFile <- loadInput localFileId doc
  uploadLocalFile <- loadInput uploadLocalFileId doc
  filename <- loadInput outputFilenameId doc
  reverseLoop <- loadInput reverseLoopGifId doc
  artist <- loadInput artistId doc
  title <- loadInput titleId doc
  applyButton <- loadButton applyId doc
  videoSource <- loadSelect videoSourceId doc
  inputSource <- loadSelect inputSourceId doc
  downloadAllButton <- loadButton downloadAllButtonId doc
  copyTranscriptButton <- loadButton copyTranscriptButtonId doc
  exportStateButton <- loadButton exportStateButtonId doc
  importStateButton <- loadButton importStateButtonId doc
  setCutStartButton <- loadButton setCutStartButton doc
  setCutEndButton <- loadButton setCutEndButton doc
  subtitleTable <- loadTable subtitleTableId doc
  addSubtitleButton <- loadButton addSubtitleId doc
  sortSubtitlesButton <- loadButton sortSubtitlesId doc
  setSubtitleStartButton <- loadButton setSubtitleStartButtonId doc
  setSubtitleEndButton <- loadButton setSubtitleEndButtonId doc
  subtitleRow <- loadTemplate subtitleRow doc
  keyboardShortcutsButton <- loadButton keyboardShortcutsButtonId doc
  resetButton <- loadButton resetButtonId doc
  importStateModalImportButton <- loadButton importStateModalImportButtonId doc
  pure
    ( HtmlInputs
        { cutStart: fst rangeTuple
        , cutEnd: snd rangeTuple
        , syncAV: syncAV
        , youtubeUrl: youtubeUrl
        , downloadFullButton: downloadFullButton
        , localFile: localFile
        , uploadLocalFile: uploadLocalFile
        , filename: filename
        , reverseLoop: reverseLoop
        , artist: artist
        , title: title
        , applyButton: applyButton
        , videoSource: videoSource
        , inputSource: inputSource
        , downloadAllButton: downloadAllButton
        , copyTranscriptButton: copyTranscriptButton
        , exportStateButton: exportStateButton
        , importStateButton: importStateButton
        , setCutStartButton: setCutStartButton
        , setCutEndButton: setCutEndButton
        , subtitleTable: subtitleTable
        , addSubtitleButton: addSubtitleButton
        , sortSubtitlesButton: sortSubtitlesButton
        , setSubtitleStartButton: setSubtitleStartButton
        , setSubtitleEndButton: setSubtitleEndButton
        , subtitleRow: subtitleRow
        , keyboardShortcutsButton: keyboardShortcutsButton
        , resetButton: resetButton
        , importStateModalImportButton: importStateModalImportButton
        }
    )

loadHtmlOutputs :: NonElementParentNode -> Effect HtmlOutputs
loadHtmlOutputs doc = do
  resultPreview <- loadResultPreview doc
  minsiLog <- loadDiv minsiLogId doc
  minsiLogTitle <- loadDiv minsiLogTitleId doc
  playbackPositionYoutube <- loadSpan playbackPositionYoutubeId doc
  playbackPositionResultMedia <- loadSpan playbackPositionResultMediaId doc
  loadingModal <- loadDiv loadingModalId doc
  loadingModalExtraContent <- loadSpan loadingModalExtraConentId doc
  minsiErrorModal <- loadDiv minsiErrorModalId doc
  clipboardOutputModal <- loadClipboardOutputModal doc
  importStateModal <- loadImportStateModal doc
  resultVideo <- loadVideo resultVideoId doc
  resultAudio <- loadAudio resultAudioId doc
  pure
    ( HtmlOutputs
        { resultPreview: resultPreview
        , minsiLog: minsiLog
        , minsiLogTitle: minsiLogTitle
        , playbackPositionYoutube: playbackPositionYoutube
        , playbackPositionResultMedia: playbackPositionResultMedia
        , loadingModal: loadingModal
        , loadingModalExtraContent: loadingModalExtraContent
        , minsiErrorModal: minsiErrorModal
        , clipboardOutputModal: clipboardOutputModal
        , importStateModal: importStateModal
        , resultVideo: resultVideo
        , resultAudio: resultAudio
        }
    )

loadHtmlVisualElements :: NonElementParentNode -> Effect HtmlVisualElements
loadHtmlVisualElements doc = do
  videoSourceRow <- loadDiv videoSourceRowId doc
  videoRow <- loadDiv videoRowId doc
  subtitlesRow <- loadDiv subtitlesRowId doc
  playbackPositionResultRow <- loadDiv playbackPositionResultRowId doc
  minsiLogBox <- loadHtmlElementClass minsiLogBoxClass doc
  pure
    ( HtmlVisualElements
        { videoSourceRow: videoSourceRow
        , videoRow: videoRow
        , subtitlesRow: subtitlesRow
        , playbackPositionResultRow: playbackPositionResultRow
        , minsiLogBox: minsiLogBox
        }
    )

-- Load Single Elements ---------------------------------------------------

loadInput :: String -> NonElementParentNode -> Effect HTMLInputElement
loadInput id = loadHtmlElementId id HI.fromElement

loadButton :: String -> NonElementParentNode -> Effect HTMLButtonElement
loadButton id = loadHtmlElementId id HB.fromElement

loadCutRange :: NonElementParentNode -> Effect (Tuple HTMLInputElement HTMLInputElement)
loadCutRange doc = do
  cutStart <- loadHtmlElementId cutStartId HI.fromElement doc
  cutEnd <- loadHtmlElementId cutEndId HI.fromElement doc
  pure (Tuple cutStart cutEnd)

loadDiv :: String -> NonElementParentNode -> Effect HTMLDivElement
loadDiv id = loadHtmlElementId id HD.fromElement

loadClipboardOutputModal :: NonElementParentNode -> Effect ClipboardOutputModal
loadClipboardOutputModal doc = do
  modal <- loadDiv clipboardOutputModalId doc
  title <- loadHeading clipboardOutputModalTitleId doc
  content <- loadPre clipboardOutputModalContentId doc
  contentCopyClipboardButton <- loadButton clipboardOutputModalCopyClipboardButtonId doc
  pure (ClipboardOutputModal { modal, title, content, contentCopyClipboardButton })

loadImportStateModal :: NonElementParentNode -> Effect ImportStateModal
loadImportStateModal doc = do
  modal <- loadDiv importStateModalId doc
  title <- loadHeading importStateModalTitleId doc
  textarea <- loadTextArea importStateModalTextareaId doc
  pure (ImportStateModal { modal, title, textarea })

loadHeading :: String -> NonElementParentNode -> Effect HTMLHeadingElement
loadHeading id = loadHtmlElementId id HH.fromElement

loadPre :: String -> NonElementParentNode -> Effect HTMLPreElement
loadPre id = loadHtmlElementId id HP.fromElement

loadTextArea :: String -> NonElementParentNode -> Effect HTMLTextAreaElement
loadTextArea id = loadHtmlElementId id HTA.fromElement

loadSelect :: String -> NonElementParentNode -> Effect HTMLSelectElement
loadSelect id = loadHtmlElementId id HS.fromElement

loadSpan :: String -> NonElementParentNode -> Effect HTMLSpanElement
loadSpan id = loadHtmlElementId id HSP.fromElement

loadTable :: String -> NonElementParentNode -> Effect HTMLTableElement
loadTable id = loadHtmlElementId id HT.fromElement

loadVideo :: String -> NonElementParentNode -> Effect HTMLVideoElement
loadVideo id = loadHtmlElementId id HV.fromElement

loadAudio :: String -> NonElementParentNode -> Effect HTMLAudioElement
loadAudio id = loadHtmlElementId id HA.fromElement

loadTemplate :: String -> NonElementParentNode -> Effect HTMLTemplateElement
loadTemplate id = loadHtmlElementId id HTP.fromElement

loadResultPreview :: NonElementParentNode -> Effect ResultPreview
loadResultPreview doc = do
  catchError
    ( do
        video <- loadVideo resultPreviewId doc
        pure (ResultPreviewVideo video)
    )
    ( \_ -> do
        iframe <- loadHtmlElementId resultPreviewId IF.fromElement doc
        pure (ResultPreviewIframe iframe)
    )
