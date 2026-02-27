module Handlers.InputVideo.Foreign where

import Components.HtmlComponents (loadComponents, resultPreviewToMaybeVideo)
import Components.HTMLVideoElement (getVideoTagCurrentTime, getVideoTagDuration, isVideoTagReady)
import Data.Maybe (maybe)
import Data.Newtype (unwrap)
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
foreign import destroyIFramePlayer :: Effect Unit
foreign import getIFramePlayerCurrentTime :: Effect Number
foreign import getIFrameVideoDuration :: Effect Number
foreign import isIFramePlayerReady :: Effect Boolean

getPlayerCurrentTime :: Effect Number
getPlayerCurrentTime = do
  components <- loadComponents
  let resultPreview = (unwrap components.htmlOutputs).resultPreview
  maybe getIFramePlayerCurrentTime getVideoTagCurrentTime (resultPreviewToMaybeVideo resultPreview)

getVideoDuration :: Effect Number
getVideoDuration = do
  components <- loadComponents
  let resultPreview = (unwrap components.htmlOutputs).resultPreview
  maybe getIFrameVideoDuration getVideoTagDuration (resultPreviewToMaybeVideo resultPreview)

isPlayerReady :: Effect Boolean
isPlayerReady = do
  components <- loadComponents
  let resultPreview = (unwrap components.htmlOutputs).resultPreview
  maybe isIFramePlayerReady isVideoTagReady (resultPreviewToMaybeVideo resultPreview)
