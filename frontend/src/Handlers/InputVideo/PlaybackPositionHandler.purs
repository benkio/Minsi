module Handlers.InputVideo.PlaybackPositionHandler where

import Conversion.Time (formatToMaxSixDigits)
import Effect (Effect)
import Handlers.InputVideo.Foreign (getPlayerCurrentTime, isPlayerReady)
import Prelude
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLParagraphElement as HP

updatePlaybackPosition :: HP.HTMLParagraphElement -> Effect Unit
updatePlaybackPosition playbackPosition = do
  playerReady <- isPlayerReady
  currentTime <- getPlayerCurrentTime
  when playerReady $ setTextContent (formatToMaxSixDigits currentTime) (HP.toNode playbackPosition)
