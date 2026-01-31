module Test.Arbitrary where

import Prelude
import Test.QuickCheck.Arbitrary (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (Gen, suchThat, chooseInt, arrayOf, elements)
import Data.Char (fromCharCode)
import Data.String.CodeUnits (fromCharArray)
import Data.Maybe (maybe)
import Data.Array.NonEmpty (cons')
import Data.Int (toNumber)
data Range = Range Number Number

instance Arbitrary Range where
  arbitrary = do
    start <- arbitrary
    -- cutVideoValidation requires start < end - 100.0 (i.e. end - start > 100 ms)
    gap <- suchThat arbitrary (\g -> g > 100.0)
    pure (Range start (start + gap))

newtype NonEmptyASCIIString = NonEmptyASCIIString String
newtype EmptyASCIIString = EmptyASCIIString String

-- A “regular” (non-scientific) non-negative decimal number for formatting tests
newtype DecimalNumber = DecimalNumber Number

instance Arbitrary NonEmptyASCIIString where
  arbitrary = do
    -- Ensure at least one non-whitespace character
    nonWhitespaceChar <- nonWhitespaceASCIIChar
    otherChars <- arrayOf asciiChar
    let allChars = [ nonWhitespaceChar ] <> otherChars
    (pure <<< NonEmptyASCIIString <<< fromCharArray) allChars

instance Arbitrary EmptyASCIIString where
  arbitrary =
    arrayOf (elements (cons' ' ' [ '\t', '\n', '\r' ])) <#>
      fromCharArray >>> EmptyASCIIString

asciiChar :: Gen Char
asciiChar = do
  code <- chooseInt 32 126
  maybe asciiChar pure (fromCharCode code)

nonWhitespaceASCIIChar :: Gen Char
nonWhitespaceASCIIChar = do
  -- ASCII codes 33-126 exclude space (32) and other control chars
  code <- chooseInt 33 126
  maybe nonWhitespaceASCIIChar pure (fromCharCode code)

instance Arbitrary DecimalNumber where
  arbitrary = do
    whole <- chooseInt 0 9999
    frac <- chooseInt 0 9999
    let n = toNumber whole + (toNumber frac / 10000.0)
    pure (DecimalNumber n)

