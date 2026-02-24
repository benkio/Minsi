module Components.HTMLVideoElement where

import Effect (Effect)
import Prelude
import Web.HTML.HTMLMediaElement (currentTime, duration, readyState)
import Web.HTML.HTMLMediaElement.ReadyState (ReadyState(..))
import Web.HTML.HTMLVideoElement (HTMLVideoElement, toHTMLMediaElement)

getVideoTagCurrentTime :: HTMLVideoElement -> Effect Number
getVideoTagCurrentTime = currentTime <<< toHTMLMediaElement

getVideoTagDuration :: HTMLVideoElement -> Effect Number
getVideoTagDuration = duration <<< toHTMLMediaElement

isVideoTagReady :: HTMLVideoElement -> Effect Boolean
isVideoTagReady v = do
  rs <- readyState (toHTMLMediaElement v)
  pure (rs == HaveEnoughData)
