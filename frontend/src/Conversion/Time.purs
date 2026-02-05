module Conversion.Time where

import Prelude
import Data.Array (take)
import Data.String.CodeUnits (fromCharArray, toCharArray)

formatToFirstFour :: Number -> String
formatToFirstFour =
  show >>> toCharArray >>> take 4 >>> fromCharArray
