module Handlers.ResultVideo.Handler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_playbackPositionResultMedia, _resultAudio, _resultVideo, _videoSource)
import Conversion.Time (formatToMaxSixDigits)
import Data.Lens (view)
import Effect (Effect)
import Effect.Timer (setInterval)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultVideo.MediaSrc (isVideoSource)
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLAudioElement as HAE
import Web.HTML.HTMLMediaElement (currentTime)
import Web.HTML.HTMLSelectElement as HSE
import Web.HTML.HTMLSpanElement as HSP
import Web.HTML.HTMLVideoElement as HVE

setResultVideoHandlers :: Effect Unit
setResultVideoHandlers = genericErrorsHandler $ do
  _ <- setInterval 1000 updatePlaybackPosition
  pure unit

updatePlaybackPosition :: Effect Unit
updatePlaybackPosition = do
  components <- loadComponents
  let
    playbackPositionResultMedia = view _playbackPositionResultMedia components
    videoSource = view _videoSource components
    resultVideo = view _resultVideo components
    resultAudio = view _resultAudio components
  selectedVideoSourceValue <- HSE.value videoSource
  let media = if isVideoSource selectedVideoSourceValue then HVE.toHTMLMediaElement resultVideo else HAE.toHTMLMediaElement resultAudio
  currentTimeValue <- currentTime media
  setTextContent (formatToMaxSixDigits currentTimeValue) (HSP.toNode playbackPositionResultMedia)
