module Validations.CutVideoValidation where

import Prelude
import Data.Validation.Semigroup (V, invalid)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (DurationRange(..))

cutVideoValidation :: Number -> Number -> V (Array String) DurationRange
cutVideoValidation start end =
  if start > end then invalid [ "start > end: " <> show start <> " " <> show end ]
  else pure $ DurationRange { start: Milliseconds start, end: Milliseconds end }
