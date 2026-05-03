module Handlers.ResultVideo.Handler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_playbackPositionResultMedia)
import Conversion.Time (formatToMaxSixDigits)
import Data.Lens (view)
import Effect (Effect)
import Effect.Timer (setInterval)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultVideo.MediaSrc (getMediaElement)
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLMediaElement (currentTime)
import Web.HTML.HTMLSpanElement as HSP

setResultVideoHandlers :: Effect Unit
setResultVideoHandlers = genericErrorsHandler $ do
  _ <- setInterval 1000 updatePlaybackPosition
  pure unit

updatePlaybackPosition :: Effect Unit
updatePlaybackPosition = do
  components <- loadComponents
  let
    playbackPositionResultMedia = view _playbackPositionResultMedia components
  media <- getMediaElement components
  currentTimeValue <- currentTime media
  setTextContent (formatToMaxSixDigits currentTimeValue) (HSP.toNode playbackPositionResultMedia)
