module Components.HtmlComponents where

import Prelude (bind, pure)

import Web.DOM.NonElementParentNode (NonElementParentNode)
import Effect (Effect)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Data.Tuple (fst, snd)
import Components.Artist (loadArtist)
import Components.CutRange (loadCutRange)
import Components.YoutubeUrl (loadYoutubeUrl)
import Components.Title (loadTitle)
import Components.Filename (loadFilename)
import Components.ReverseLoop (loadReverseLoop)
import Components.ResultPreview (loadResultPreview)

data HtmlComponents = HtmlComponents
    { cutStart :: HTMLInputElement
    , cutEnd :: HTMLInputElement
    , youtubeUrl :: HTMLInputElement
    , filename :: HTMLInputElement
    , reverseLoop :: HTMLInputElement
    , artist :: HTMLInputElement
    , title :: HTMLInputElement
    , resultPreview :: HTMLVideoElement
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
  pure (HtmlComponents
    { cutStart : fst rangeTuple
    , cutEnd : snd rangeTuple
    , youtubeUrl : youtubeUrl
    , filename : filename
    , reverseLoop : reverseLoop
    , artist : artist
    , title : title
    , resultPreview : resultPreview
    })
