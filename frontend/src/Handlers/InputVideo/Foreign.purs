module Handlers.InputVideo.Foreign where

import Components.HtmlComponents (loadComponents, resultPreviewToMaybeIframe, resultPreviewToMaybeVideo)
import Components.HTMLVideoElement (getVideoTagCurrentTime, getVideoTagDuration, isVideoTagReady)
import Data.Maybe (Maybe(..))
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
  case resultPreviewToMaybeVideo resultPreview of
    Nothing -> getIFramePlayerCurrentTime
    Just v -> getVideoTagCurrentTime v

getVideoDuration :: Effect Number
getVideoDuration = do
  components <- loadComponents
  let resultPreview = (unwrap components.htmlOutputs).resultPreview
  case resultPreviewToMaybeVideo resultPreview of
    Nothing -> getIFrameVideoDuration
    Just v -> getVideoTagDuration v

isPlayerReady :: Effect Boolean
isPlayerReady = do
  components <- loadComponents
  let resultPreview = (unwrap components.htmlOutputs).resultPreview
  case resultPreviewToMaybeVideo resultPreview of
    Nothing -> isIFramePlayerReady
    Just v -> isVideoTagReady v
