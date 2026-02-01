module Handlers.VideoSourceHandler where

import Prelude
import Handers.ErrorHandlers (genericErrorsHandler)
import Handlers.ApplyButtonHandler (getCurrentState, setVideoSrc)
import Data.Newtype (unwrap)
import Data.Tuple (fst)
import Constants (gif, mp4)
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Effect (Effect)
import Effect.Console (log)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.Event.EventTypes as E

setVideoSourceHandler :: HS.HTMLSelectElement -> HTMLVideoElement -> Effect Unit
setVideoSourceHandler videoSource video = genericErrorsHandler $ do
  videoSourceEvL <- eventListener (videoSourceEventListener videoSource video)
  addEventListener E.change videoSourceEvL false videoSourceEventTarget
  where
  videoSourceEventTarget = toEventTarget (HS.toElement videoSource)

videoSourceEventListener :: HS.HTMLSelectElement -> HTMLVideoElement -> Event -> Effect Unit
videoSourceEventListener videoSource video _ = genericErrorsHandler $ do
  stateTuple <- getCurrentState
  let filename = (unwrap (fst stateTuple)).filename
  selectedValue <- HS.value videoSource
  case selectedValue of
    "video" -> setVideoSrc (mp4 filename) video
    "gif"   -> setVideoSrc (gif filename) video
    v       -> log $ "⚠️ Unexpected VideoSource Input: " <> v
