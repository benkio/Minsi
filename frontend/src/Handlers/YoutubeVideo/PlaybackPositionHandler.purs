module Handlers.YoutubeVideo.PlaybackPositionHandler where

import Conversion.Time (formatToThreeDecimals)
import Effect (Effect)
import Handlers.YoutubeVideo.Foreign (getPlayerCurrentTime, isPlayerReady)
import Prelude
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLSpanElement as HSP

updatePlaybackPosition :: HSP.HTMLSpanElement -> Effect Unit
updatePlaybackPosition playbackPosition = do
  playerReady <- isPlayerReady
  currentTime <- getPlayerCurrentTime
  when playerReady $ setTextContent (formatToThreeDecimals currentTime) (HSP.toNode playbackPosition)
