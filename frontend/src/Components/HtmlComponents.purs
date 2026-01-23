module Components.HtmlComponents where

import Prelude (bind, pure)

import Components.HTMLComponentsLoader (loadHtmlElement)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Effect (Effect)
import Components.HtmlIds
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
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV
import Data.Tuple (Tuple(..), fst, snd)

data HtmlInputs = HtmlInputs
  { cutStart :: HTMLInputElement
  , cutEnd :: HTMLInputElement
  , youtubeUrl :: HTMLInputElement
  , filename :: HTMLInputElement
  , reverseLoop :: HTMLInputElement
  , artist :: HTMLInputElement
  , title :: HTMLInputElement
  , applyButton :: HTMLButtonElement
  , videoSource :: HTMLSelectElement
  , setCutEndButton :: HTMLButtonElement
  , setCutStartButton :: HTMLButtonElement
  }

data HtmlOutputs = HtmlOutputs
  { resultPreview :: HTMLDivElement
  , addSubtitleButton :: HTMLButtonElement
  , minsiLog :: HTMLDivElement
  , playbackPosition :: HTMLSpanElement
    , cutStartValue  :: HTMLSpanElement
    , cutEndValue  :: HTMLSpanElement
    , loadingModal :: HTMLDivElement
    , resultVideo :: HTMLVideoElement
  }
type HtmlComponents = Tuple HtmlInputs HtmlOutputs

loadComponents :: NonElementParentNode -> Effect HtmlComponents
loadComponents doc = do
  inputs <- loadHtmlInputs doc
  outputs <- loadHtmlOutputs doc
  pure (Tuple inputs outputs)

loadHtmlInputs :: NonElementParentNode -> Effect HtmlInputs
loadHtmlInputs doc = do
  rangeTuple <- loadCutRange doc
  youtubeUrl <- loadInput youtubeUrlId doc
  filename <- loadInput outputFilenameId doc
  reverseLoop <- loadInput reverseLoopGifId doc
  artist <- loadInput artistId doc
  title <- loadInput titleId doc
  applyButton <- loadButton applyId doc
  videoSource <- loadVideoSource doc
  setCutStartButton <- loadButton setCutStartButton doc
  setCutEndButton <- loadButton setCutEndButton doc
  pure
    ( HtmlInputs
        { cutStart: fst rangeTuple
        , cutEnd: snd rangeTuple
        , youtubeUrl: youtubeUrl
        , filename: filename
        , reverseLoop: reverseLoop
        , artist: artist
        , title: title
        , applyButton: applyButton
        , videoSource: videoSource
        , setCutStartButton: setCutStartButton
        , setCutEndButton: setCutEndButton
        }
    )

loadHtmlOutputs :: NonElementParentNode -> Effect HtmlOutputs
loadHtmlOutputs doc = do
  resultPreview <- loadDiv resultPreviewId doc
  addSubtitleButton <- loadButton addSubtitleId doc
  minsiLog <- loadDiv minsiLogId doc
  playbackPosition <- loadSpan playbackPositionId doc
  cutStartValue <- loadSpan cutStartValueId doc
  cutEndValue <- loadSpan cutEndValueId doc
  loadingModal <- loadDiv loadingModalId doc
  resultVideo <- loadVideo resultVideoId doc
  pure
    ( HtmlOutputs
        { resultPreview: resultPreview
        , addSubtitleButton: addSubtitleButton
        , minsiLog: minsiLog
        , playbackPosition: playbackPosition
        , cutStartValue: cutStartValue
        , cutEndValue: cutEndValue
        , loadingModal: loadingModal
        , resultVideo: resultVideo
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

loadVideo :: String -> NonElementParentNode -> Effect HTMLVideoElement
loadVideo id = loadHtmlElement id HV.fromElement
