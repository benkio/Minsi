module Handlers.VideoSourceHandler where

import Prelude
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
setVideoSourceHandler videoSource video = do
  stateTuple <- getCurrentState
  let state = fst stateTuple
  let filename = (unwrap state).filename
  videoSourceEvL <- eventListener (videoSourceEventListener filename videoSource video)
  addEventListener E.change videoSourceEvL false videoSourceEventTarget
  where
  videoSourceEventTarget = toEventTarget (HS.toElement videoSource)

videoSourceEventListener :: String -> HS.HTMLSelectElement -> HTMLVideoElement -> Event -> Effect Unit
videoSourceEventListener filename videoSource video _ = do
  selectedValue <- HS.value videoSource
  case selectedValue of
    "video" -> setVideoSrc filepathMp4 video
    "gif"   -> setVideoSrc filepathGif video
    v       -> log $ "⚠️ Unexpected VideoSource Input: " <> v
  where
    filepathMp4 = mp4 filename
    filepathGif = gif filename
