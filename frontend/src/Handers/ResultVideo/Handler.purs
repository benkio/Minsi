module Handlers.ResultVideo.Handler where

import Prelude

import Effect (Effect)
import Effect.Timer (setInterval)
import Handers.ErrorHandlers (genericErrorsHandler)
import Handers.YoutubeVideo.PlaybackPositionHandler (formatToThreeDecimals)
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLMediaElement (currentTime)
import Web.HTML.HTMLSpanElement as HSP
import Web.HTML.HTMLVideoElement (HTMLVideoElement, toHTMLMediaElement)

data ResultVideoEventTargets = RVET
  { playbackPositionResultVideo :: HSP.HTMLSpanElement
  , resultVideo :: HTMLVideoElement
  }

setResultVideoHandlers :: ResultVideoEventTargets -> Effect Unit
setResultVideoHandlers (RVET { playbackPositionResultVideo, resultVideo }) = do
  _ <- setInterval 1000 (updatePlaybackPosition playbackPositionResultVideo resultVideo)
  pure unit

updatePlaybackPosition :: HSP.HTMLSpanElement -> HTMLVideoElement -> Effect Unit
updatePlaybackPosition playbackPositionResultVideo resultVideo = genericErrorsHandler $ do
  currentTimeValue <- currentTime (toHTMLMediaElement resultVideo)
  setTextContent (formatToThreeDecimals currentTimeValue) (HSP.toNode playbackPositionResultVideo)
