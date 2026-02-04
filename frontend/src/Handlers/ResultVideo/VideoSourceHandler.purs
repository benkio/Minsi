module Handlers.ResultVideo.VideoSourceHandler where

import Prelude
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ApplyButtonHandler (getCurrentState, setResultMediaSrc)
import Data.Newtype (unwrap)
import Data.Tuple (fst)
import Web.HTML.HTMLAudioElement (HTMLAudioElement)
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Effect (Effect)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.Event.EventTypes as E

setVideoSourceHandler :: HS.HTMLSelectElement -> HTMLVideoElement -> HTMLAudioElement -> Effect Unit
setVideoSourceHandler videoSource resultVideo resultAudio = genericErrorsHandler $ do
  videoSourceEvL <- eventListener (videoSourceEventListener videoSource resultVideo resultAudio)
  addEventListener E.change videoSourceEvL false videoSourceEventTarget
  where
  videoSourceEventTarget = toEventTarget (HS.toElement videoSource)

videoSourceEventListener :: HS.HTMLSelectElement -> HTMLVideoElement -> HTMLAudioElement -> Event -> Effect Unit
videoSourceEventListener videoSource resultVideo resultAudio _ = genericErrorsHandler $ do
  stateTuple <- getCurrentState
  let filename = (unwrap (fst stateTuple)).filename
  setResultMediaSrc filename videoSource resultVideo resultAudio
