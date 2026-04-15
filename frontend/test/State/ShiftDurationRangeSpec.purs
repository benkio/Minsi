module Test.State.ShiftDurationRangeSpec where

import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (DurationRange(..), shiftDurationRange)

spec :: Spec Unit
spec = do
  describe "shiftDurationRange" do
    it "should shift start and end of duration range by the offset" $ do
      let
        original = DurationRange { start: Milliseconds 10.0, end: Milliseconds 20.0 }
        shifted = shiftDurationRange (Milliseconds 5.0) original
      shifted `shouldEqual` DurationRange { start: Milliseconds 15.0, end: Milliseconds 25.0 }
      original `shouldEqual` DurationRange { start: Milliseconds 10.0, end: Milliseconds 20.0 }
