module Handlers.InputVideo.InputSourceHandler where

import Prelude

import Components.HtmlComponents (HtmlInputs(..), loadComponents, showLocalfileInput, showYoutubeUrlInput)
import Components.HtmlComponents.Lenses (_inputSource)
import Data.Lens (view)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLSelectElement as HS

setInputSourceHandler :: Effect Unit
setInputSourceHandler = genericErrorsHandler $ do
  components <- loadComponents
  let
    inputs = components.htmlInputs
    inputSource = view _inputSource components
    inputSourceEventTarget = toEventTarget (HS.toElement inputSource)
  inputSourceEvL <- eventListener (inputSourceEventListener inputs)
  addEventListener E.change inputSourceEvL false inputSourceEventTarget

inputSourceEventListener :: HtmlInputs -> Event -> Effect Unit
inputSourceEventListener inputs@(HtmlInputs { inputSource }) _ = do
  selectedInputSourceValue <- HS.value inputSource
  case selectedInputSourceValue of
    "youtubeUrl" ->
      showYoutubeUrlInput inputs
    "localFile" ->
      showLocalfileInput inputs
    x -> throwMinsiError (InvalidInput "inputSource" x)
