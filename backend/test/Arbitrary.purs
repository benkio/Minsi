module Test.Arbitrary where

import Data.Time.Duration (Milliseconds(..))
import Model.State (DurationRange(..))
import Prelude
import Test.QuickCheck.Arbitrary (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (suchThat)

data Range = Range Number Number

instance Arbitrary Range where
  arbitrary = do
    start <- arbitrary
    gap <- suchThat arbitrary (\g -> g > 100.0)
    pure (Range start (start + gap))

-- | DurationRange that satisfies validateRange: start < end - 100 (i.e. end - start > 100 ms)
newtype ValidDurationRange = ValidDurationRange DurationRange

instance Arbitrary ValidDurationRange where
  arbitrary = do
    start <- arbitrary
    gap <- suchThat arbitrary (\g -> g > 100.0)
    pure $ ValidDurationRange $ DurationRange
      { start: Milliseconds start
      , end: Milliseconds (start + gap)
      }

-- | DurationRange that fails validateRange: start >= end - 100 (i.e. end - start <= 100 ms)
newtype InvalidDurationRange = InvalidDurationRange DurationRange

instance Arbitrary InvalidDurationRange where
  arbitrary = do
    start <- arbitrary
    gap <- suchThat arbitrary (\g -> g >= 0.0 && g <= 100.0)
    pure $ InvalidDurationRange $ DurationRange
      { start: Milliseconds start
      , end: Milliseconds (start + gap)
      }

