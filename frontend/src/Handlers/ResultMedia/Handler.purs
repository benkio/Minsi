module Handlers.ResultMedia.Handler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_playbackPositionResultMedia)
import Conversion.Time (formatToMaxSixDigits)
import Data.Lens (view)
import Effect (Effect)
import Effect.Timer (setInterval)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultMedia.MediaSrc (getMediaElement)
import Web.DOM.Node (setTextContent, textContent)
import Web.HTML.HTMLMediaElement (currentTime, duration)
import Web.HTML.HTMLParagraphElement as HP

setResultMediaHandlers :: Effect Unit
setResultMediaHandlers = genericErrorsHandler $ do
  _ <- setInterval 1000 updatePlaybackPosition
  pure unit

updatePlaybackPosition :: Effect Unit
updatePlaybackPosition = do
  components <- loadComponents
  let
    playbackPositionResultMedia = view _playbackPositionResultMedia components
    node = HP.toNode playbackPositionResultMedia
  media <- getMediaElement components
  currentTime <- currentTime media
  duration <- duration media
  let
    remainingTime = duration - currentTime
    newValue = formatToMaxSixDigits currentTime <> "/" <> formatToMaxSixDigits remainingTime
  oldValue <- textContent node
  when (oldValue /= newValue) $ setTextContent newValue node
