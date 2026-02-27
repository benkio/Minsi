module Handlers.ResultVideo.VideoSourceHandler where

import Data.Newtype (unwrap)
import Data.Tuple (fst)
import Effect (Effect)
import Handlers.ResultVideo.MediaSrc (setResultMediaSrc)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Model.State.StateFromHtml (getCurrentState)
import Prelude
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLAudioElement (HTMLAudioElement)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLVideoElement (HTMLVideoElement)

setVideoSourceHandler :: HS.HTMLSelectElement -> HTMLVideoElement -> HTMLAudioElement -> Effect Unit
setVideoSourceHandler videoSource resultVideo resultAudio = genericErrorsHandler $ do
  videoSourceEvL <- eventListener (videoSourceEventListener videoSource resultVideo resultAudio)
  addEventListener E.change videoSourceEvL false videoSourceEventTarget
  where
  videoSourceEventTarget = toEventTarget (HS.toElement videoSource)

videoSourceEventListener :: HS.HTMLSelectElement -> HTMLVideoElement -> HTMLAudioElement -> Event -> Effect Unit
videoSourceEventListener videoSource resultVideo resultAudio _ = do
  stateTuple <- getCurrentState
  let filename = (unwrap (fst stateTuple)).filename
  setResultMediaSrc filename videoSource resultVideo resultAudio
