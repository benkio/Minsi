module Handers.YoutubeVideo.PlaybackPositionHandler where

import Data.Array (replicate, span, tail, take)
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

--TODO: move it to an appropriate place and test
formatToThreeDecimals :: Number -> String
formatToThreeDecimals v =
  let
    { init: i, rest: r } = span (\x -> x /= '.') <<< toCharArray $ show v
    num = fromCharArray i
    decChars = maybe [] identity (tail r)
    dec3 = take 3 (decChars <> replicate 3 '0')
    dec = fromCharArray dec3
  in
    num <> "." <> dec
