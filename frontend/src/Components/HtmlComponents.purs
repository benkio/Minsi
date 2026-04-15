module Components.HtmlComponents where

import Components.HTMLComponentsLoader (loadHtmlElementClass, loadHtmlElementId)
import Components.HtmlIdAndClasses
  ( addSubtitleId
  , applyId
  , artistId
  , cutEndId
  , cutStartId
  , subtitleOffsetId
  , loadingModalId
  , minsiErrorModalId
  , minsiLogId
  , outputFilenameId
  , playbackPositionResultRowId
  , playbackPositionResultVideoId
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

newtype HtmlInputs = HtmlInputs
  { cutStart :: HTMLInputElement
  , cutEnd :: HTMLInputElement
  , subtitleOffset :: HTMLInputElement
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
  , setCutEndButton :: HTMLButtonElement
  , setCutStartButton :: HTMLButtonElement
  , subtitleTable :: HTMLTableElement
  , addSubtitleButton :: HTMLButtonElement
  , sortSubtitlesButton :: HTMLButtonElement
  , setSubtitleStartButton :: HTMLButtonElement
  , setSubtitleEndButton :: HTMLButtonElement
  , subtitleRow :: HTMLTemplateElement
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

newtype HtmlOutputs = HtmlOutputs
  { resultPreview :: ResultPreview
  , minsiLog :: HTMLDivElement
  , minsiLogTitle :: HTMLDivElement
  , playbackPositionYoutube :: HTMLSpanElement
  , playbackPositionResultVideo :: HTMLSpanElement
  , loadingModal :: HTMLDivElement
  , minsiErrorModal :: HTMLDivElement
  , resultVideo :: HTMLVideoElement
  , resultAudio :: HTMLAudioElement
  , keyboardShortcutsButton :: HTMLButtonElement
  , resetButton :: HTMLButtonElement
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
  subtitleOffset <- loadInput subtitleOffsetId doc
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
  setCutStartButton <- loadButton setCutStartButton doc
  setCutEndButton <- loadButton setCutEndButton doc
  subtitleTable <- loadTable subtitleTableId doc
  addSubtitleButton <- loadButton addSubtitleId doc
  sortSubtitlesButton <- loadButton sortSubtitlesId doc
  setSubtitleStartButton <- loadButton setSubtitleStartButtonId doc
  setSubtitleEndButton <- loadButton setSubtitleEndButtonId doc
  subtitleRow <- loadTemplate subtitleRow doc
  pure
    ( HtmlInputs
        { cutStart: fst rangeTuple
        , cutEnd: snd rangeTuple
        , subtitleOffset: subtitleOffset
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
        , setCutStartButton: setCutStartButton
        , setCutEndButton: setCutEndButton
        , subtitleTable: subtitleTable
        , addSubtitleButton: addSubtitleButton
        , sortSubtitlesButton: sortSubtitlesButton
        , setSubtitleStartButton: setSubtitleStartButton
        , setSubtitleEndButton: setSubtitleEndButton
        , subtitleRow: subtitleRow
        }
    )

loadHtmlOutputs :: NonElementParentNode -> Effect HtmlOutputs
loadHtmlOutputs doc = do
  resultPreview <- loadResultPreview doc
  minsiLog <- loadDiv minsiLogId doc
  minsiLogTitle <- loadDiv minsiLogTitleId doc
  playbackPositionYoutube <- loadSpan playbackPositionYoutubeId doc
  playbackPositionResultVideo <- loadSpan playbackPositionResultVideoId doc
  loadingModal <- loadDiv loadingModalId doc
  minsiErrorModal <- loadDiv minsiErrorModalId doc
  resultVideo <- loadVideo resultVideoId doc
  resultAudio <- loadAudio resultAudioId doc
  keyboardShortcutsButton <- loadButton keyboardShortcutsButtonId doc
  resetButton <- loadButton resetButtonId doc
  pure
    ( HtmlOutputs
        { resultPreview: resultPreview
        , minsiLog: minsiLog
        , minsiLogTitle: minsiLogTitle
        , playbackPositionYoutube: playbackPositionYoutube
        , playbackPositionResultVideo: playbackPositionResultVideo
        , loadingModal: loadingModal
        , minsiErrorModal: minsiErrorModal
        , resultVideo: resultVideo
        , resultAudio: resultAudio
        , keyboardShortcutsButton: keyboardShortcutsButton
        , resetButton: resetButton
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
