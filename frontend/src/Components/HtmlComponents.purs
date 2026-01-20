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
  }

data HtmlOutputs = HtmlOutputs
  { resultPreview :: HTMLDivElement
  , addSubtitleButton :: HTMLButtonElement
  , minsiLog :: HTMLDivElement
  , playbackPosition :: HTMLSpanElement
  }

type HtmlComponents = Tuple HtmlInputs HtmlOutputs

loadComponents :: NonElementParentNode -> Effect HtmlComponents
loadComponents doc = do
  rangeTuple <- loadCutRange doc
  youtubeUrl <- loadYoutubeUrl doc
  filename <- loadFilename doc
  reverseLoop <- loadReverseLoop doc
  artist <- loadArtist doc
  title <- loadTitle doc
  applyButton <- loadApplyButton doc
  videoSource <- loadVideoSource doc
  resultPreview <- loadResultPreview doc
  addSubtitleButton <- loadAddSubtitleButton doc
  minsiLog <- loadMinsiLog doc
  playbackPosition <- loadPlaybackPosition doc
  pure
    ( Tuple
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
            }
        )
        ( HtmlOutputs
            { resultPreview: resultPreview
            , addSubtitleButton: addSubtitleButton
            , minsiLog: minsiLog
            , playbackPosition: playbackPosition
            }
        )
    )

-- Load Single Elements ---------------------------------------------------

loadArtist :: NonElementParentNode -> Effect HTMLInputElement
loadArtist = loadHtmlElement artistId HI.fromElement

loadApplyButton :: NonElementParentNode -> Effect HTMLButtonElement
loadApplyButton = loadHtmlElement applyId HB.fromElement

loadCutRange :: NonElementParentNode -> Effect (Tuple HTMLInputElement HTMLInputElement)
loadCutRange doc = do
  cutStart <- loadHtmlElement cutStartId HI.fromElement doc
  cutEnd <- loadHtmlElement cutEndId HI.fromElement doc
  pure (Tuple cutStart cutEnd)

loadCutVideoButton :: NonElementParentNode -> Effect HTMLButtonElement
loadCutVideoButton = loadHtmlElement cutVideoId HB.fromElement

loadFilename :: NonElementParentNode -> Effect HTMLInputElement
loadFilename = loadHtmlElement outputFilenameId HI.fromElement

loadAddSubtitleButton :: NonElementParentNode -> Effect HTMLButtonElement
loadAddSubtitleButton = loadHtmlElement addSubtitleId HB.fromElement

loadResultPreview :: NonElementParentNode -> Effect HTMLDivElement
loadResultPreview = loadHtmlElement resultPreviewId HD.fromElement

loadReverseLoop :: NonElementParentNode -> Effect HTMLInputElement
loadReverseLoop = loadHtmlElement reverseLoopGifId HI.fromElement

loadTitle :: NonElementParentNode -> Effect HTMLInputElement
loadTitle = loadHtmlElement titleId HI.fromElement

loadYoutubeUrl :: NonElementParentNode -> Effect HTMLInputElement
loadYoutubeUrl = loadHtmlElement youtubeUrlId HI.fromElement

loadVideoSource :: NonElementParentNode -> Effect HTMLSelectElement
loadVideoSource = loadHtmlElement videoSourceId HS.fromElement

loadMinsiLog :: NonElementParentNode -> Effect HTMLDivElement
loadMinsiLog = loadHtmlElement minsiLogId HD.fromElement

loadPlaybackPosition :: NonElementParentNode -> Effect HTMLSpanElement
loadPlaybackPosition = loadHtmlElement playbackPositionId HSP.fromElement
