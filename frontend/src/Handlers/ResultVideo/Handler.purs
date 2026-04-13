module Handlers.ResultVideo.Handler where

import Prelude

import Conversion.Time (formatToMaxSixDigits)
import Effect (Effect)
import Effect.Timer (setInterval)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultVideo.MediaSrc (isVideoSource)
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLAudioElement (HTMLAudioElement, toHTMLMediaElement)
import Web.HTML.HTMLAudioElement as HAE
import Web.HTML.HTMLMediaElement (currentTime)
import Web.HTML.HTMLSelectElement (HTMLSelectElement)
import Web.HTML.HTMLSelectElement as HSE
import Web.HTML.HTMLSpanElement as HSP
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HVE

data ResultVideoEventTargets = RVET
  { playbackPositionResultVideo :: HSP.HTMLSpanElement
  , resultVideo :: HTMLVideoElement
  , resultAudio :: HTMLAudioElement
  , videoSource :: HTMLSelectElement
  }

setResultVideoHandlers :: ResultVideoEventTargets -> Effect Unit
setResultVideoHandlers resultVideoEventTargets = genericErrorsHandler $ do
  _ <- setInterval 1000 (updatePlaybackPosition resultVideoEventTargets)
  pure unit

updatePlaybackPosition :: ResultVideoEventTargets -> Effect Unit
updatePlaybackPosition (RVET { playbackPositionResultVideo, videoSource, resultVideo, resultAudio }) = do
  selectedVideoSourceValue <- HSE.value videoSource
  let media = if isVideoSource selectedVideoSourceValue then HVE.toHTMLMediaElement resultVideo else HAE.toHTMLMediaElement resultAudio
  currentTimeValue <- currentTime media
  setTextContent (formatToMaxSixDigits currentTimeValue) (HSP.toNode playbackPositionResultVideo)
