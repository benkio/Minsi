module Conversion.Time where

import Data.Array (take, filter)
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Prelude

formatToFirstFour :: Number -> String
formatToFirstFour =
  show >>> toCharArray >>> take 5 >>> filter isDigit >>> fromCharArray
  where
  isDigit c = c >= '0' && c <= '9'
