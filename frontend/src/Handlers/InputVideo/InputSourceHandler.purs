module Handlers.InputVideo.InputSourceHandler where

import Prelude

import Components.HTMLElement (addClassToElement, removeClassFromElement)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS

setInputSourceHandler :: HS.HTMLSelectElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Effect Unit
setInputSourceHandler inputSource youtubeUrl localFile = genericErrorsHandler $ do
  inputSourceEvL <- eventListener (inputSourceEventListener inputSource youtubeUrl localFile)
  addEventListener E.change inputSourceEvL false inputSourceEventTarget
  where
  inputSourceEventTarget = toEventTarget (HS.toElement inputSource)

inputSourceEventListener :: HS.HTMLSelectElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
inputSourceEventListener inputSource youtubeUrl localFile _ = do
  selectedInputSourceValue <- HS.value inputSource
  case selectedInputSourceValue of
    "youtubeUrl" -> addClassToElement "d-none" (HI.toElement localFile) *> removeClassFromElement "d-none" (HI.toElement youtubeUrl)
    "localFile" -> addClassToElement "d-none" (HI.toElement youtubeUrl) *> removeClassFromElement "d-none" (HI.toElement localFile)
    x -> throwMinsiError (InvalidInput "inputSource" x)
