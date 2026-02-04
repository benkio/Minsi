module Handlers.ResultVideo.VideoSourceHandler where

import Web.HTML.HTMLSourceElement (HTMLSourceElement)

import Prelude
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ApplyButtonHandler (getCurrentState, setVideoSrc)
import Data.Newtype (unwrap)
import Data.Tuple (fst)
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Effect (Effect)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.Event.EventTypes as E

setVideoSourceHandler :: HS.HTMLSelectElement -> HTMLVideoElement -> HTMLSourceElement -> Effect Unit
setVideoSourceHandler videoSource resultVideo resultVideoSource = genericErrorsHandler $ do
  videoSourceEvL <- eventListener (videoSourceEventListener videoSource resultVideo resultVideoSource)
  addEventListener E.change videoSourceEvL false videoSourceEventTarget
  where
  videoSourceEventTarget = toEventTarget (HS.toElement videoSource)

videoSourceEventListener :: HS.HTMLSelectElement -> HTMLVideoElement -> HTMLSourceElement -> Event -> Effect Unit
videoSourceEventListener videoSource resultVideo resultVideoSource _ = genericErrorsHandler $ do
  stateTuple <- getCurrentState
  let filename = (unwrap (fst stateTuple)).filename
  setVideoSrc filename resultVideo videoSource resultVideoSource
