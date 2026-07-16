module Handlers.InputVideo.PlaybackPositionHandler where

import Conversion.Time (formatToMaxSixDigits)
import Effect (Effect)
import Handlers.InputVideo.Foreign (getPlayerCurrentTime, isPlayerReady)
import Prelude
import Web.DOM.Node (setTextContent, textContent)
import Web.HTML.HTMLParagraphElement as HP

updatePlaybackPosition :: HP.HTMLParagraphElement -> Effect Unit
updatePlaybackPosition playbackPosition = do
  playerReady <- isPlayerReady
  currentTime <- getPlayerCurrentTime
  let
    node = HP.toNode playbackPosition
    newValue = formatToMaxSixDigits currentTime
  oldValue <- textContent node
  when (playerReady && oldValue /= newValue) $ setTextContent newValue node
