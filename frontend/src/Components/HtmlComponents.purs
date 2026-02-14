module Components.HtmlComponents where

import Components.HTMLComponentsLoader (loadHtmlElement)
import Components.HtmlIds
  ( addSubtitleId
  , applyId
  , artistId
  , cutEndId
  , cutStartId
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
  , setCutEndButton
  , setCutStartButton
  , setSubtitleEndButtonId
  , setSubtitleStartButtonId
  , subtitleTableId
  , subtitlesRowId
  , titleId
  , videoRowId
  , videoSourceId
  , videoSourceRowId
  , downloadButtonId
  , downloadAllButtonId
  , copyTranscriptButtonId
  , youtubeUrlId
  , subtitleRow
  , keyboardShortcutsButtonId
  , localFileId
  )
import Control.Monad.Error.Class (catchError)
import Data.Newtype (class Newtype)
import Data.Tuple (Tuple(..), fst, snd)
import Effect (Effect)
import Prelude (bind, pure)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLDivElement (HTMLDivElement)
import Web.HTML.HTMLDivElement as HD
import Web.HTML.HTMLSelectElement (HTMLSelectElement)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLSpanElement (HTMLSpanElement)
import Web.HTML.HTMLSpanElement as HSP
import Web.HTML.HTMLAudioElement (HTMLAudioElement)
import Web.HTML.HTMLAudioElement as HA
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV
import Web.HTML.HTMLIFrameElement (HTMLIFrameElement)
import Web.HTML.HTMLIFrameElement as IF
import Web.HTML.HTMLTableElement (HTMLTableElement)
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTemplateElement (HTMLTemplateElement)
import Web.HTML.HTMLTemplateElement as HTP

newtype HtmlInputs = HtmlInputs
  { cutStart :: HTMLInputElement
  , cutEnd :: HTMLInputElement
  , youtubeUrl :: HTMLInputElement
  , localFile :: HTMLInputElement
  , filename :: HTMLInputElement
  , reverseLoop :: HTMLInputElement
  , artist :: HTMLInputElement
  , title :: HTMLInputElement
  , applyButton :: HTMLButtonElement
  , videoSource :: HTMLSelectElement
  , downloadButton :: HTMLButtonElement
  , downloadAllButton :: HTMLButtonElement
  , copyTranscriptButton :: HTMLButtonElement
  , setCutEndButton :: HTMLButtonElement
  , setCutStartButton :: HTMLButtonElement
  , subtitleTable :: HTMLTableElement
  , addSubtitleButton :: HTMLButtonElement
  , setSubtitleStartButton :: HTMLButtonElement
  , setSubtitleEndButton :: HTMLButtonElement
  , subtitleRow :: HTMLTemplateElement
  }

data ResultPreview
  = ResultPreviewDiv HTMLDivElement
  | ResultPreviewIframe HTMLIFrameElement

newtype HtmlOutputs = HtmlOutputs
  { resultPreview :: ResultPreview
  , minsiLog :: HTMLDivElement
  , playbackPositionYoutube :: HTMLSpanElement
  , playbackPositionResultVideo :: HTMLSpanElement
  , loadingModal :: HTMLDivElement
  , minsiErrorModal :: HTMLDivElement
  , resultVideo :: HTMLVideoElement
  , resultAudio :: HTMLAudioElement
  , keyboardShortcutsButton :: HTMLButtonElement
  }

derive instance Newtype HtmlOutputs _
derive instance Newtype HtmlInputs _

data HtmlVisualElements = HtmlVisualElements
  { videoSourceRow :: HTMLDivElement
  , videoRow :: HTMLDivElement
  , subtitlesRow :: HTMLDivElement
  , playbackPositionResultRow :: HTMLDivElement
  }

type HtmlComponents =
  { htmlInputs :: HtmlInputs
  , htmlOutputs :: HtmlOutputs
  , htmlVisualElements :: HtmlVisualElements
  }

loadComponents :: NonElementParentNode -> Effect HtmlComponents
loadComponents doc = do
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
  youtubeUrl <- loadInput youtubeUrlId doc
  localFile <- loadInput localFileId doc
  filename <- loadInput outputFilenameId doc
  reverseLoop <- loadInput reverseLoopGifId doc
  artist <- loadInput artistId doc
  title <- loadInput titleId doc
  applyButton <- loadButton applyId doc
  videoSource <- loadVideoSource doc
  downloadButton <- loadButton downloadButtonId doc
  downloadAllButton <- loadButton downloadAllButtonId doc
  copyTranscriptButton <- loadButton copyTranscriptButtonId doc
  setCutStartButton <- loadButton setCutStartButton doc
  setCutEndButton <- loadButton setCutEndButton doc
  subtitleTable <- loadTable subtitleTableId doc
  addSubtitleButton <- loadButton addSubtitleId doc
  setSubtitleStartButton <- loadButton setSubtitleStartButtonId doc
  setSubtitleEndButton <- loadButton setSubtitleEndButtonId doc
  subtitleRow <- loadTemplate subtitleRow doc
  pure
    ( HtmlInputs
        { cutStart: fst rangeTuple
        , cutEnd: snd rangeTuple
        , youtubeUrl: youtubeUrl
        , localFile: localFile
        , filename: filename
        , reverseLoop: reverseLoop
        , artist: artist
        , title: title
        , applyButton: applyButton
        , videoSource: videoSource
        , downloadButton: downloadButton
        , downloadAllButton: downloadAllButton
        , copyTranscriptButton: copyTranscriptButton
        , setCutStartButton: setCutStartButton
        , setCutEndButton: setCutEndButton
        , subtitleTable: subtitleTable
        , addSubtitleButton: addSubtitleButton
        , setSubtitleStartButton: setSubtitleStartButton
        , setSubtitleEndButton: setSubtitleEndButton
        , subtitleRow: subtitleRow
        }
    )

loadHtmlOutputs :: NonElementParentNode -> Effect HtmlOutputs
loadHtmlOutputs doc = do
  resultPreview <- loadResultPreview doc
  minsiLog <- loadDiv minsiLogId doc
  playbackPositionYoutube <- loadSpan playbackPositionYoutubeId doc
  playbackPositionResultVideo <- loadSpan playbackPositionResultVideoId doc
  loadingModal <- loadDiv loadingModalId doc
  minsiErrorModal <- loadDiv minsiErrorModalId doc
  resultVideo <- loadVideo resultVideoId doc
  resultAudio <- loadAudio resultAudioId doc
  keyboardShortcutsButton <- loadButton keyboardShortcutsButtonId doc
  pure
    ( HtmlOutputs
        { resultPreview: resultPreview
        , minsiLog: minsiLog
        , playbackPositionYoutube: playbackPositionYoutube
        , playbackPositionResultVideo: playbackPositionResultVideo
        , loadingModal: loadingModal
        , minsiErrorModal: minsiErrorModal
        , resultVideo: resultVideo
        , resultAudio: resultAudio
        , keyboardShortcutsButton: keyboardShortcutsButton
        }
    )

loadHtmlVisualElements :: NonElementParentNode -> Effect HtmlVisualElements
loadHtmlVisualElements doc = do
  videoSourceRow <- loadDiv videoSourceRowId doc
  videoRow <- loadDiv videoRowId doc
  subtitlesRow <- loadDiv subtitlesRowId doc
  playbackPositionResultRow <- loadDiv playbackPositionResultRowId doc
  pure
    ( HtmlVisualElements
        { videoSourceRow: videoSourceRow
        , videoRow: videoRow
        , subtitlesRow: subtitlesRow
        , playbackPositionResultRow: playbackPositionResultRow
        }
    )

-- Load Single Elements ---------------------------------------------------

loadInput :: String -> NonElementParentNode -> Effect HTMLInputElement
loadInput id = loadHtmlElement id HI.fromElement

loadButton :: String -> NonElementParentNode -> Effect HTMLButtonElement
loadButton id = loadHtmlElement id HB.fromElement

loadCutRange :: NonElementParentNode -> Effect (Tuple HTMLInputElement HTMLInputElement)
loadCutRange doc = do
  cutStart <- loadHtmlElement cutStartId HI.fromElement doc
  cutEnd <- loadHtmlElement cutEndId HI.fromElement doc
  pure (Tuple cutStart cutEnd)

loadDiv :: String -> NonElementParentNode -> Effect HTMLDivElement
loadDiv id = loadHtmlElement id HD.fromElement

loadVideoSource :: NonElementParentNode -> Effect HTMLSelectElement
loadVideoSource = loadHtmlElement videoSourceId HS.fromElement

loadSpan :: String -> NonElementParentNode -> Effect HTMLSpanElement
loadSpan id = loadHtmlElement id HSP.fromElement

loadTable :: String -> NonElementParentNode -> Effect HTMLTableElement
loadTable id = loadHtmlElement id HT.fromElement

loadVideo :: String -> NonElementParentNode -> Effect HTMLVideoElement
loadVideo id = loadHtmlElement id HV.fromElement

loadAudio :: String -> NonElementParentNode -> Effect HTMLAudioElement
loadAudio id = loadHtmlElement id HA.fromElement

loadTemplate :: String -> NonElementParentNode -> Effect HTMLTemplateElement
loadTemplate id = loadHtmlElement id HTP.fromElement

loadResultPreview :: NonElementParentNode -> Effect ResultPreview
loadResultPreview doc = do
  catchError
    ( do
        div <- loadDiv resultPreviewId doc
        pure (ResultPreviewDiv div)
    )
    ( \_ -> do
        iframe <- loadHtmlElement resultPreviewId IF.fromElement doc
        pure (ResultPreviewIframe iframe)
    )
