module Handlers.InputVideo.InputSourceHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_downloadFullButton, _inputSource, _localFile, _youtubeUrl)
import Components.HTMLElement (addClassToElement, removeClassFromElement)
import Data.Lens (view)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS

setInputSourceHandler :: Effect Unit
setInputSourceHandler = genericErrorsHandler $ do
  components <- loadComponents
  let
    inputSource = view _inputSource components
    youtubeUrl = view _youtubeUrl components
    localFile = view _localFile components
    downloadFullButton = view _downloadFullButton components
    inputSourceEventTarget = toEventTarget (HS.toElement inputSource)
  inputSourceEvL <- eventListener (inputSourceEventListener inputSource youtubeUrl localFile downloadFullButton)
  addEventListener E.change inputSourceEvL false inputSourceEventTarget

inputSourceEventListener :: HS.HTMLSelectElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> HB.HTMLButtonElement -> Event -> Effect Unit
inputSourceEventListener inputSource youtubeUrl localFile downloadFullButton _ = do
  selectedInputSourceValue <- HS.value inputSource
  case selectedInputSourceValue of
    "youtubeUrl" ->
      addClassToElement "d-none" (HI.toElement localFile)
        *> removeClassFromElement "d-none" (HI.toElement youtubeUrl)
        *>
          removeClassFromElement "d-none" (HB.toElement downloadFullButton)
    "localFile" ->
      addClassToElement "d-none" (HI.toElement youtubeUrl)
        *> addClassToElement "d-none" (HB.toElement downloadFullButton)
        *>
          removeClassFromElement "d-none" (HI.toElement localFile)
    x -> throwMinsiError (InvalidInput "inputSource" x)
