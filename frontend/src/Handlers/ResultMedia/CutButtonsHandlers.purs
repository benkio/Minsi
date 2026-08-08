module Handlers.ResultMedia.CutButtonsHandlers where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_cutEnd, _cutStart, _setResultCutEndButton, _setResultCutStartButton, _uploadLocalFile)
import Components.HtmlIdAndClasses (cutEndId, cutStartId)
import Data.Lens (view)
import Data.Int (floor)
import Data.Validation.Semigroup (validation)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultMedia.MediaSrc (getMediaElement)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ValidationErrors (toMap)
import Validations.DurationRangeValidation (durationRangeValidation)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement (valueAsNumber)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLMediaElement (HTMLMediaElement, currentTime, duration)

setResultCutButtonsHandlers :: Effect Unit
setResultCutButtonsHandlers = genericErrorsHandler $ do
  components <- loadComponents
  let
    setResultCutStartButton = view _setResultCutStartButton components
    setResultCutEndButton = view _setResultCutEndButton components
    cutStart = view _cutStart components
    cutEnd = view _cutEnd components
    uploadLocalFile = view _uploadLocalFile components
  media <- getMediaElement components
  startButtonEvL <- eventListener (setResultCutStartButtonEvL media cutStart cutEnd uploadLocalFile)
  endButtonEvL <- eventListener (setResultCutEndButtonEvL media cutStart cutEnd uploadLocalFile)
  addEventListener E.click startButtonEvL false (toEventTarget (HB.toElement setResultCutStartButton))
  addEventListener E.click endButtonEvL false (toEventTarget (HB.toElement setResultCutEndButton))

setResultCutStartButtonEvL :: HTMLMediaElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
setResultCutStartButtonEvL media cutStart cutEnd uploadLocalFile _ = genericErrorsHandler do
  log "[ResultMedia] set result cut start button clicked"
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  currentTime <- currentTime media
  let newStart = start + (currentTime * 1000.0)
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> log "[ResultMedia] set the uploadLocalFile to true" *> HI.setChecked true uploadLocalFile *> HI.setValue (show (floor newStart)) cutStart)
    (durationRangeValidation cutStartId newStart end)

setResultCutEndButtonEvL :: HTMLMediaElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
setResultCutEndButtonEvL media cutStart cutEnd uploadLocalFile _ = genericErrorsHandler do
  log "[ResultMedia] set result cut end button clicked"
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  currentTime <- currentTime media
  duration <- duration media
  let
    remainingTime = duration - currentTime
    newEnd = end - (remainingTime * 1000.0)
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> log "[ResultMedia] set the uploadLocalFile to true" *> HI.setChecked true uploadLocalFile *> HI.setValue (show (floor newEnd)) cutEnd)
    (durationRangeValidation cutEndId start newEnd)
