module Test.Model.StateSpec where

import Data.Either (isLeft, isRight)
import Effect.Class (liftEffect)
import Model.State (validateRange)
import Prelude
import Test.Arbitrary (InvalidDurationRange(..), ValidDurationRange(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)

spec :: Spec Unit
spec = do
  describe "validateRange" do
    it "returns Left if the duration range is invalid" $ liftEffect $
      quickCheck \(InvalidDurationRange range) -> isLeft (validateRange range)
    it "returns Right if the duration range is valid" $ liftEffect $
      quickCheck \(ValidDurationRange range) -> isRight (validateRange range)
