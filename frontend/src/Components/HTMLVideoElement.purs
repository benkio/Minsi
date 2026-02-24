module Components.HTMLVideoElement where

import Prelude

import Effect (Effect)
import Effect.Console (log)

-- TODO: implement
isVideoTagReady :: Effect Boolean
isVideoTagReady = log "isVideoTagReady" *> pure true
getVideoTagDuration :: Effect Number
getVideoTagDuration = log "getVideoTagDuration" *> pure 42.0
getVideoTagCurrentTime :: Effect Number
getVideoTagCurrentTime = log "getVideoCurrentTime" *> pure 69.0
