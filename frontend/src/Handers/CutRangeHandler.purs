module Handlers.CutRangeHandler where

import Handers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Effect (Effect)
import Prelude
import Control.Monad (when)
import Data.Int (floor)
import Web.HTML.HTMLInputElement (value, valueAsNumber, setValue)
import Web.HTML.HTMLInputElement as HI
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E

data CutRangeTargets = CRET
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
  , cutStartValue :: HI.HTMLInputElement
  , cutEndValue :: HI.HTMLInputElement
  }

setCutRangeHandlers :: CutRangeTargets -> Effect Unit
setCutRangeHandlers (CRET { cutStart, cutEnd, cutStartValue, cutEndValue }) = genericErrorsHandler $ do
  cutStartEvL <- eventListener (rangeToNumberListener cutStart cutStartValue)
  cutEndEvL <- eventListener (rangeToNumberListener cutEnd cutEndValue)
  cutStartValueEvL <- eventListener (numberToRangeListener cutStart cutStartValue)
  cutEndValueEvL <- eventListener (numberToRangeListener cutEnd cutEndValue)
  addEventListener E.input cutStartEvL false (toEventTarget (HI.toElement cutStart))
  addEventListener E.change cutStartEvL false (toEventTarget (HI.toElement cutStart))
  addEventListener E.input cutEndEvL false (toEventTarget (HI.toElement cutEnd))
  addEventListener E.change cutEndEvL false (toEventTarget (HI.toElement cutEnd))
  addEventListener E.input cutStartValueEvL false (toEventTarget (HI.toElement cutStartValue))
  addEventListener E.change cutStartValueEvL false (toEventTarget (HI.toElement cutStartValue))
  addEventListener E.input cutEndValueEvL false (toEventTarget (HI.toElement cutEndValue))
  addEventListener E.change cutEndValueEvL false (toEventTarget (HI.toElement cutEndValue))
  pure unit

-- When range changes, update the number input (both in milliseconds)
rangeToNumberListener :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
rangeToNumberListener rangeInput numberInput _ = do
  rangeVal <- value rangeInput
  HI.setValue rangeVal numberInput

-- When number input changes, update the range (both in milliseconds)
numberToRangeListener :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
numberToRangeListener rangeInput numberInput _ = do
  numVal <- valueAsNumber numberInput
  when (not (nan numVal) && numVal >= 0.0) $
    HI.setValue (show (floor numVal)) rangeInput
  where
  nan x = x /= x

updateCutValue :: Number -> HI.HTMLInputElement -> Effect Unit
updateCutValue numMs cutValueInput = HI.setValue (show (floor numMs)) cutValueInput

