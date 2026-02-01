module Handlers.CutRangeHandler where

import Main.MinsiError (MinsiError(..), throwMinsiError)
import Data.Maybe (maybe)
import Conversion.Time (formatToThreeDecimals)
import Data.Int (fromString, toNumber)
import Handers.ErrorHandlers (genericErrorsHandler)
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
setCutRangeHandlers (CRET { cutStart, cutEnd, cutStartValue, cutEndValue }) = genericErrorsHandler $ do
  cutStartEvL <- eventListener (cutEventListener cutStart cutStartValue)
  cutEndEvL <- eventListener (cutEventListener cutEnd cutEndValue)
  addEventListener E.input cutStartEvL false cutStartEventTarget
  addEventListener E.change cutStartEvL false cutStartEventTarget
  addEventListener E.input cutEndEvL false cutEndEventTarget
  addEventListener E.change cutEndEvL false cutEndEventTarget
  pure unit
  where
  cutStartEventTarget = toEventTarget (HI.toElement cutStart)
  cutEndEventTarget = toEventTarget (HI.toElement cutEnd)


cutEventListener :: HI.HTMLInputElement -> HS.HTMLSpanElement -> Event -> Effect Unit
cutEventListener cutElement cutElementValue _ = do
  inputValue <- value cutElement
  numValue <- maybe (throwMinsiError (InvalidInput "CutElement" inputValue)) pure (fromString inputValue)
  setTextContent (formatToThreeDecimals (toNumber numValue)) (HS.toNode cutElementValue)


updateCutValue :: Number -> HS.HTMLSpanElement -> Effect Unit
updateCutValue num cutValueSpan = setTextContent (formatToThreeDecimals num) (HS.toNode cutValueSpan)

