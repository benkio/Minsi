module Handlers.CutRangeHandler where

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_cutEnd, _cutStart, _uploadLocalFile)
import Components.HtmlIdAndClasses (cutEndId, cutStartId)
import Data.Lens (view)
import Data.Validation.Semigroup (validation)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ValidationErrors (toMap)
import Prelude
import Validations.DurationRangeValidation (durationRangeValidation)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLInputElement (valueAsNumber)
import Web.HTML.HTMLInputElement as HI

setCutRangeHandlers :: Effect Unit
setCutRangeHandlers = genericErrorsHandler $ do
  components <- loadComponents
  let cutStart = view _cutStart components
  let cutEnd = view _cutEnd components
  let uploadLocalFile = view _uploadLocalFile components
  cutStartEvL <- eventListener (rangeToNumberListenerStart cutStart cutEnd uploadLocalFile)
  cutEndEvL <- eventListener (rangeToNumberListenerEnd cutStart cutEnd uploadLocalFile)
  addEventListener E.input cutStartEvL false (toEventTarget (HI.toElement cutStart))
  addEventListener E.change cutStartEvL false (toEventTarget (HI.toElement cutStart))
  addEventListener E.input cutEndEvL false (toEventTarget (HI.toElement cutEnd))
  addEventListener E.change cutEndEvL false (toEventTarget (HI.toElement cutEnd))
  pure unit

-- When start range changes, update start number input if durationRangeValidation is satisfied
rangeToNumberListenerStart :: HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
rangeToNumberListenerStart cutStart cutEnd uploadLocalFile _ = genericErrorsHandler $ do
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> log "[CutRangeHandler] set the uploadLocalFile to true" *> HI.setChecked true uploadLocalFile)
    (durationRangeValidation cutStartId start end)

-- When end range changes, update end number input if durationRangeValidation is satisfied
rangeToNumberListenerEnd :: HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
rangeToNumberListenerEnd cutStart cutEnd uploadLocalFile _ = genericErrorsHandler $ do
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEnd
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> log "[CutRangeHandler] set the uploadLocalFile to true" *> HI.setChecked true uploadLocalFile)
    (durationRangeValidation cutEndId start end)
