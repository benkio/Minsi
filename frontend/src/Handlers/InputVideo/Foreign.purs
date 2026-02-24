module Handlers.InputVideo.Foreign where

import Effect (Effect)
import Prelude

type EmbedVideoConfig =
  { resultPreviewId :: String
  , videoId :: String
  , width :: Int
  , height :: Int
  , startTime :: Int
  }

foreign import embedIFrameVideo :: EmbedVideoConfig -> Effect Unit
foreign import getIFramePlayerCurrentTime :: Effect Number
foreign import getIFrameVideoDuration :: Effect Number
foreign import isIFramePlayerReady :: Effect Boolean

embedVideo :: EmbedVideoConfig -> Effect Unit
embedVideo = embedIFrameVideo

getPlayerCurrentTime :: Effect Number
getPlayerCurrentTime = getIFramePlayerCurrentTime

getVideoDuration :: Effect Number
getVideoDuration = getIFrameVideoDuration

isPlayerReady :: Effect Boolean
isPlayerReady = isIFramePlayerReady
