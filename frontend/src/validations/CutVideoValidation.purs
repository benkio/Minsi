module Validations.CutVideoValidation where

import Data.Map (Map, singleton)
import Prelude
import Data.Validation.Semigroup (V, invalid)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (DurationRange(..))

cutVideoValidation :: String -> Number -> Number -> V (Map String String) DurationRange
cutVideoValidation id start end =
  if start >= end - 100.0 then -- 100 milliseconds are not percevable
    invalid (singleton id ("start >= end - 100: " <> show start <> " " <> show end))
  else
    pure $ DurationRange { start: Milliseconds start, end: Milliseconds end }
