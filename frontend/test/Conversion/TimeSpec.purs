module Test.Conversion.TimeSpec where

import Conversion.Time (formatToFirstFour)
import Data.String.CodeUnits (length)
import Effect.Class (liftEffect)
import Prelude
import Test.Arbitrary (DecimalNumber(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)

spec :: Spec Unit
spec = do
  describe "formatToFirstFour" do
    it "Takes only the first 4 numbers" $ liftEffect do
      quickCheck \(DecimalNumber n) -> length (formatToFirstFour n) == 4
