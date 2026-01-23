module Handlers.CutRangeHandler where

import Web.HTML.HTMLSpanElement as HS
import Web.DOM.Element (toEventTarget)
import Web.DOM.Node (setTextContent)
import Effect (Effect)
import Prelude
import Web.HTML.HTMLInputElement (value)
import Web.HTML.HTMLInputElement as HI
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E

data CutRangeTargets = CRET
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
  , cutStartValue :: HS.HTMLSpanElement
  , cutEndValue :: HS.HTMLSpanElement
  }

setCutRangeHandlers :: CutRangeTargets -> Effect Unit
setCutRangeHandlers (CRET {cutStart, cutEnd, cutStartValue, cutEndValue}) = do
  cutStartEvL <- eventListener (cutStartEventListener cutStart cutStartValue)
  cutEndEvL <- eventListener (cutEndEventListener cutEnd cutEndValue)
  addEventListener E.input cutStartEvL false cutStartEventTarget
  addEventListener E.change cutStartEvL false cutStartEventTarget
  addEventListener E.input cutEndEvL false cutEndEventTarget
  addEventListener E.change cutEndEvL false cutEndEventTarget
  pure unit
  where
    cutStartEventTarget = toEventTarget (HI.toElement cutStart)
    cutEndEventTarget = toEventTarget (HI.toElement cutEnd)

cutStartEventListener :: HI.HTMLInputElement -> HS.HTMLSpanElement -> Event -> Effect Unit
cutStartEventListener cutStart cutStartValue _ = do
  inputValue <- value cutStart
  setTextContent inputValue (HS.toNode cutStartValue)

cutEndEventListener :: HI.HTMLInputElement -> HS.HTMLSpanElement -> Event -> Effect Unit
cutEndEventListener cutEnd cutEndValue _ = do
  inputValue <- value cutEnd
  setTextContent inputValue (HS.toNode cutEndValue)

-- Helper functions to update display values programmatically
updateCutStartValue :: HI.HTMLInputElement -> HS.HTMLSpanElement -> Effect Unit
updateCutStartValue cutStart cutStartValue = do
  inputValue <- value cutStart
  setTextContent inputValue (HS.toNode cutStartValue)

updateCutEndValue :: HI.HTMLInputElement -> HS.HTMLSpanElement -> Effect Unit
updateCutEndValue cutEnd cutEndValue = do
  inputValue <- value cutEnd
  setTextContent inputValue (HS.toNode cutEndValue)

-- Generic function to update any cut value display
updateCutValue :: HI.HTMLInputElement -> HS.HTMLSpanElement -> Effect Unit
updateCutValue cutInput cutValueSpan = do
  inputValue <- value cutInput
  setTextContent inputValue (HS.toNode cutValueSpan)

