module Handlers.CutRangeHandler where

import Components.HtmlIds (cutEndId, cutStartId)
import Data.Validation.Semigroup (validation)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.ValidationErrors (toMap)
import Prelude
import Validations.CutVideoValidation (cutVideoValidation)
import Web.DOM.Element (toEventTarget)
import Web.HTML.HTMLInputElement (valueAsNumber)
import Web.HTML.HTMLInputElement as HI
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Data.Int (floor)

data CutRangeTargets = CRET
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
  , cutStartValue :: HI.HTMLInputElement
  , cutEndValue :: HI.HTMLInputElement
  }

setCutRangeHandlers :: CutRangeTargets -> Effect Unit
setCutRangeHandlers (CRET { cutStart, cutEnd, cutStartValue, cutEndValue }) = genericErrorsHandler $ do
  cutStartEvL <- eventListener (rangeToNumberListenerStart cutStart cutEnd cutStartValue cutEndValue)
  cutEndEvL <- eventListener (rangeToNumberListenerEnd cutStart cutEnd cutStartValue cutEndValue)
  cutStartValueEvL <- eventListener (numberToRangeListenerStart cutStart cutEndValue cutStartValue)
  cutEndValueEvL <- eventListener (numberToRangeListenerEnd cutEnd cutStartValue cutEndValue)
  addEventListener E.input cutStartEvL false (toEventTarget (HI.toElement cutStart))
  addEventListener E.change cutStartEvL false (toEventTarget (HI.toElement cutStart))
  addEventListener E.input cutEndEvL false (toEventTarget (HI.toElement cutEnd))
  addEventListener E.change cutEndEvL false (toEventTarget (HI.toElement cutEnd))
  addEventListener E.input cutStartValueEvL false (toEventTarget (HI.toElement cutStartValue))
  addEventListener E.change cutStartValueEvL false (toEventTarget (HI.toElement cutStartValue))
  addEventListener E.input cutEndValueEvL false (toEventTarget (HI.toElement cutEndValue))
  addEventListener E.change cutEndValueEvL false (toEventTarget (HI.toElement cutEndValue))
  pure unit

-- When start range changes, update start number input if cutVideoValidation is satisfied
rangeToNumberListenerStart :: HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
rangeToNumberListenerStart cutStart _ cutStartValue cutEndValue _ = genericErrorsHandler $ do
  start <- valueAsNumber cutStart
  end <- valueAsNumber cutEndValue
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> HI.setValue (show start) cutStartValue)
    (cutVideoValidation cutStartId start end)

-- When end range changes, update end number input if cutVideoValidation is satisfied
rangeToNumberListenerEnd :: HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
rangeToNumberListenerEnd _ cutEnd cutStartValue cutEndValue _ = genericErrorsHandler $ do
  start <- valueAsNumber cutStartValue
  end <- valueAsNumber cutEnd
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> HI.setValue (show end) cutEndValue)
    (cutVideoValidation cutStartId start end)

-- When start number input changes, update start range if cutVideoValidation is satisfied
numberToRangeListenerStart :: HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
numberToRangeListenerStart cutStart cutEndValue cutStartValue _ = genericErrorsHandler $ do
  start <- valueAsNumber cutStartValue
  end <- valueAsNumber cutEndValue
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> HI.setValue (show start) cutStart)
    (cutVideoValidation cutStartId start end)

-- When end number input changes, update end range if cutVideoValidation is satisfied
numberToRangeListenerEnd :: HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
numberToRangeListenerEnd cutEnd cutStartValue cutEndValue _ = genericErrorsHandler $ do
  start <- valueAsNumber cutStartValue
  end <- valueAsNumber cutEndValue
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> HI.setValue (show end) cutEnd)
    (cutVideoValidation cutEndId start end)

updateCutValue :: Number -> HI.HTMLInputElement -> Effect Unit
updateCutValue numMs cutValueInput = HI.setValue (show (floor numMs)) cutValueInput
