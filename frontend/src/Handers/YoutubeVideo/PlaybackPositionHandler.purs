module Handers.YoutubeVideo.PlaybackPositionHandler where

import Effect (Effect)
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLSpanElement as HSP
import Handers.YoutubeVideo.Foreign (getPlayerCurrentTime, isPlayerReady)
import Prelude
import Data.String (split, length)
import Data.String.Pattern (Pattern(..))
import Data.Array (head,span, tail, take)
import Data.Maybe (maybe)
import Data.Int (floor, toNumber)
import Data.String.CodeUnits (toCharArray, fromCharArray)

updatePlaybackPosition :: HSP.HTMLSpanElement -> Effect Unit
updatePlaybackPosition playbackPosition = do
  playerReady <- isPlayerReady
  currentTime <- getPlayerCurrentTime
  when playerReady $ setTextContent (formatToThreeDecimals currentTime) (HSP.toNode playbackPosition)
  where
    formatToThreeDecimals :: Number -> String
    formatToThreeDecimals v =
      let
        {init:i, rest:r} = span (\x -> x /='.') <<< toCharArray $ show v
        num = fromCharArray i
        dec = maybe "0" fromCharArray $ take 3 <$> tail r
      in num <> "." <> dec
