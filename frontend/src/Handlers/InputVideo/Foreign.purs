module Handlers.InputVideo.Foreign where

import Prelude
import Effect (Effect)

type EmbedVideoConfig =
  { resultPreviewId :: String
  , videoId :: String
  , width :: Int
  , height :: Int
  , startTime :: Int
  }

foreign import embedVideo :: EmbedVideoConfig -> Effect Unit
foreign import getPlayerCurrentTime :: Effect Number
foreign import getVideoDuration :: Effect Number
foreign import isPlayerReady :: Effect Boolean
