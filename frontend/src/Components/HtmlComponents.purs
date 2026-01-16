module Components.HtmlComponents where

import Prelude (bind, pure)

import Web.DOM.NonElementParentNode (NonElementParentNode)
import Effect (Effect)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Data.Tuple (fst, snd)
import Components.Artist (loadArtist)
import Components.CutRange (loadCutRange)
import Components.YoutubeUrl (loadYoutubeUrl)
import Components.Title (loadTitle)
import Components.Filename (loadFilename)
import Components.ReverseLoop (loadReverseLoop)
import Components.ResultPreview (loadResultPreview)
import Components.CutVideoButton (loadCutVideoButton)
import Components.AddSubtitleButton (loadAddSubtitleButton)
import Components.ApplySubtitleButton (loadApplySubtitleButton)

data HtmlComponents = HtmlComponents
    { cutStart :: HTMLInputElement
    , cutEnd :: HTMLInputElement
    , youtubeUrl :: HTMLInputElement
    , filename :: HTMLInputElement
    , reverseLoop :: HTMLInputElement
    , artist :: HTMLInputElement
    , title :: HTMLInputElement
    , resultPreview :: HTMLVideoElement
    , cutVideoButton:: HTMLButtonElement
    , applySubtitleButton:: HTMLButtonElement
    , addSubtitleButton:: HTMLButtonElement
    }

loadComponents :: NonElementParentNode -> Effect HtmlComponents
loadComponents doc = do
  artist <- loadArtist doc
  rangeTuple <- loadCutRange doc
  youtubeUrl <- loadYoutubeUrl doc
  filename <- loadFilename doc
  reverseLoop <- loadReverseLoop doc
  title <- loadTitle doc
  resultPreview <- loadResultPreview doc
  cutVideoButton <- loadCutVideoButton doc
  applySubtitleButton <- loadApplySubtitleButton doc
  addSubtitleButton <- loadAddSubtitleButton doc
  pure (HtmlComponents
    { cutStart : fst rangeTuple
    , cutEnd : snd rangeTuple
    , youtubeUrl : youtubeUrl
    , filename : filename
    , reverseLoop : reverseLoop
    , artist : artist
    , title : title
    , resultPreview : resultPreview
    , cutVideoButton: cutVideoButton
    , addSubtitleButton: addSubtitleButton
    , applySubtitleButton: applySubtitleButton
    })
