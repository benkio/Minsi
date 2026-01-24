module Handers.YoutubeVideo.PlaybackPositionHandler where

import Data.Array (span, tail, take)
import Data.Maybe (maybe)
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Effect (Effect)
import Handers.YoutubeVideo.Foreign (getPlayerCurrentTime, isPlayerReady)
import Prelude
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLSpanElement as HSP

updatePlaybackPosition :: HSP.HTMLSpanElement -> Effect Unit
updatePlaybackPosition playbackPosition = do
  playerReady <- isPlayerReady
  currentTime <- getPlayerCurrentTime
  when playerReady $ setTextContent (formatToThreeDecimals currentTime) (HSP.toNode playbackPosition)
  where
    formatToThreeDecimals :: Number -> String
    formatToThreeDecimals v =
      let
        { init: i, rest: r } = span (\x -> x /= '.') <<< toCharArray $ show v
        num = fromCharArray i
        dec = maybe "0" fromCharArray $ take 3 <$> tail r
      in
        num <> "." <> dec
