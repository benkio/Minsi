module Handlers.CutRangeHandler where

import Web.HTML.HTMLSpanElement as HS
import Web.DOM.Element (fromEventTarget, toEventTarget)
import Effect (Effect)
import Prelude
import Web.HTML.HTMLInputElement as HI

data CutRangeTargets = CRET
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
  , cutStartValue :: HS.HTMLSpanElement
  , cutEndValue :: HS.HTMLSpanElement
  }

setCutRangeHandlers :: CutRangeTargets -> Effect Unit
setCutRangeHandlers (CRET {cutStart, cutEnd, cutStartValue, cutEndValue}) = pure unit --TODO: implement
  where
    cutStartEventTarget = toEventTarget (HI.toElement cutStart)
    cutEndEventTarget = toEventTarget (HI.toElement cutEnd)

-- cutStartEvl :: HI.HTMLInputElement -> Event -> Effect Unit
-- cutStartEvl cutStart 

