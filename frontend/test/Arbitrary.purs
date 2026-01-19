module Test.Arbitrary where

import Prelude
import Test.QuickCheck.Arbitrary (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (Gen, suchThat, chooseInt, arrayOf1, arrayOf, elements)
import Data.Char (fromCharCode)
import Data.String.CodeUnits (fromCharArray)
import Data.Maybe (maybe)
import Data.Array.NonEmpty (toArray)
import Data.Array.NonEmpty.Internal (NonEmptyArray(..))

data Range = Range Number Number

instance Arbitrary Range where
  arbitrary = do
    start <- arbitrary
    end <- suchThat arbitrary (\x -> x >= start)
    pure (Range start end)

newtype NonEmptyASCIIString = NonEmptyASCIIString String
newtype EmptyASCIIString = EmptyASCIIString String

instance Arbitrary NonEmptyASCIIString where
  arbitrary = do
    chars <- arrayOf1 asciiChar
    (pure <<< NonEmptyASCIIString <<< fromCharArray <<< toArray) chars

instance Arbitrary EmptyASCIIString where
  arbitrary =
    arrayOf (elements (NonEmptyArray [ ' ', '\t', '\n', '\r' ])) <#>
      fromCharArray >>> EmptyASCIIString

asciiChar :: Gen Char
asciiChar = do
  code <- chooseInt 32 126
  maybe asciiChar pure (fromCharCode code)

