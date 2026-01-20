module Test.Validations.CutVideoValidationSpec where

import Prelude
import Effect.Class (liftEffect)
import Test.Arbitrary (Range(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)
import Data.Validation.Semigroup (isValid)
import Validations.CutVideoValidation (cutVideoValidation)

spec :: Spec Unit
spec = do
  describe "cutVideoValidation" do
    it "should validate when the range is valid" $ liftEffect $
      quickCheck (\(Range s e) -> isValid (cutVideoValidation s e))
    it "should not validate when the range is invalid" $ liftEffect $
      quickCheck (\(Range s e) -> not (isValid (cutVideoValidation (e + 1.0) s)))
