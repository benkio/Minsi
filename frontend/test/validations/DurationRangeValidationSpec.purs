module Test.Validations.DurationRangeValidationSpec where

import Prelude
import Effect.Class (liftEffect)
import Test.Arbitrary (Range(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)
import Data.Validation.Semigroup (isValid)
import Validations.DurationRangeValidation (durationRangeValidation)

spec :: Spec Unit
spec = do
  describe "durationRangeValidation" do
    it "should validate when the range is valid" $ liftEffect $
      quickCheck (\(Range s e) -> isValid (durationRangeValidation "testId" s e))
    it "should not validate when the range is invalid" $ liftEffect $
      quickCheck (\(Range s e) -> not (isValid (durationRangeValidation "testId" (e + 1.0) s)))
