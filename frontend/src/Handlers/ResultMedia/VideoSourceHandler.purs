module Handlers.ResultMedia.VideoSourceHandler where

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_resultAudio, _resultVideo, _videoSource)
import Data.Lens (view)
import Data.Tuple (fst)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultMedia.MediaSrc (setResultMediaSrc)
import Model.State.Lenses (_filename)
import Model.State.StateFromHtml (getCurrentState)
import Prelude
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLAudioElement (HTMLAudioElement)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLVideoElement (HTMLVideoElement)

setVideoSourceHandler :: Effect Unit
setVideoSourceHandler = genericErrorsHandler $ do
  components <- loadComponents
  let
    videoSource = view _videoSource components
    resultVideo = view _resultVideo components
    resultAudio = view _resultAudio components
    videoSourceEventTarget = toEventTarget (HS.toElement videoSource)
  videoSourceEvL <- eventListener (videoSourceEventListener videoSource resultVideo resultAudio)
  addEventListener E.change videoSourceEvL false videoSourceEventTarget

videoSourceEventListener :: HS.HTMLSelectElement -> HTMLVideoElement -> HTMLAudioElement -> Event -> Effect Unit
videoSourceEventListener videoSource resultVideo resultAudio _ = genericErrorsHandler $ do
  stateTuple <- getCurrentState
  let filename = view _filename (fst stateTuple)
  setResultMediaSrc filename videoSource resultVideo resultAudio
