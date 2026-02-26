module Test.Conversion.TimeSpec where

import Conversion.Time (formatToMaxSixDigits)
import Data.Array (dropWhile, tail, take, takeWhile, length) as A
import Data.Maybe (maybe)
import Data.String.CodeUnits (length, toCharArray)
import Effect.Class (liftEffect)
import Prelude
import Test.Arbitrary (DecimalNumber(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)

spec :: Spec Unit
spec = do
  describe "formatToMaxSixDigits" do
    it "Returns all integer digits plus up to 3 decimal digits" $ liftEffect do
      quickCheck \(DecimalNumber n) ->
        let
          chars = toCharArray (show n)
          intDigitCount = A.length (A.takeWhile (_ /= '.') chars)
          fracDigitCount = A.length (maybe [] (A.take 3) (A.tail (A.dropWhile (_ /= '.') chars)))
          expected = intDigitCount + fracDigitCount
        in
          length (formatToMaxSixDigits n) == expected
