module Validations.DurationRangeValidation where

import Prelude
import Data.Validation.Semigroup (V, invalid)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (DurationRange(..))
import Model.ValidationErrors (ValidationErrors, fromSingleton)

durationRangeValidation :: String -> Number -> Number -> V ValidationErrors DurationRange
durationRangeValidation id start end =
  if start >= end - 100.0 then -- 100 milliseconds are not percevable

    invalid (fromSingleton id ("start >= end - 100: " <> show start <> " " <> show end))
  else
    pure $ DurationRange { start: Milliseconds start, end: Milliseconds end }
