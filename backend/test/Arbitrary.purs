module Test.Arbitrary where

import Prelude

import Data.Array as Array
import Data.Array.NonEmpty as NEA
import Data.Char (fromCharCode)
import Data.Maybe (Maybe(..))
import Data.String.CodeUnits (fromCharArray)
import Data.Time.Duration (Milliseconds(..))
import Data.Traversable (traverse)
import Model.State (DurationRange(..))
import Test.QuickCheck.Arbitrary (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (Gen, choose, suchThat, arrayOf1, chooseInt)

data Range = Range Number Number

instance Arbitrary Range where
  arbitrary = do
    start <- arbitrary
    -- arbitrary for Number is uniform [0,1]; use choose so gap is always > 100
    gap <- choose 100.1 10000.0
    pure (Range start (start + gap))

-- | DurationRange that satisfies validateRange: start < end - 100 (i.e. end - start > 100 ms)
newtype ValidDurationRange = ValidDurationRange DurationRange

instance Arbitrary ValidDurationRange where
  arbitrary = do
    start <- arbitrary
    gap <- choose 100.1 10000.0
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

-- | Non-empty array of valid DurationRanges (for validateSubtitles tests)
newtype NonEmptyValidDurationRanges = NonEmptyValidDurationRanges (Array DurationRange)

instance Arbitrary NonEmptyValidDurationRanges where
  arbitrary = do
    nea <- arrayOf1 arbitrary
    pure $ NonEmptyValidDurationRanges (map (\(ValidDurationRange r) -> r) (NEA.toArray nea))

-- | Non-empty array of invalid DurationRanges (for validateSubtitles tests)
newtype NonEmptyInvalidDurationRanges = NonEmptyInvalidDurationRanges (Array DurationRange)

instance Arbitrary NonEmptyInvalidDurationRanges where
  arbitrary = do
    nea <- arrayOf1 arbitrary
    pure $ NonEmptyInvalidDurationRanges (map (\(InvalidDurationRange r) -> r) (NEA.toArray nea))

newtype LongerThanNCharacters = LongerThanNCharacters { n :: Int, value :: String }

instance Arbitrary LongerThanNCharacters where
  arbitrary = do
    n <- chooseInt 0 50
    extra <- chooseInt 1 20
    let len = n + 50 + extra
    s <- replicateChar len
    pure $ LongerThanNCharacters { n, value: s }

replicateChar :: Int -> Gen String
replicateChar len = fromCharArray <$> traverse (const randomAsciiChar) (Array.replicate len unit)

randomAsciiChar :: Gen Char
randomAsciiChar = do
  c <- fromCharCode <$> chooseInt 32 126
  case c of
    Just ch -> pure ch
    Nothing -> randomAsciiChar
