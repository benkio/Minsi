module Handers.YoutubeVideo.PlaybackPositionHandler where

import Effect (Effect)
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLSpanElement as HSP
import Handers.YoutubeVideo.Foreign (getPlayerCurrentTime, isPlayerReady)
import Prelude

updatePlaybackPosition :: HSP.HTMLSpanElement -> Effect Unit
updatePlaybackPosition playbackPosition = do
  playerReady <- isPlayerReady
  currentTime <- getPlayerCurrentTime
  when playerReady $ setTextContent (show currentTime) (HSP.toNode playbackPosition)
