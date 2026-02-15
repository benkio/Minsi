module Conversion.String where

import Prelude

import Data.Array (modifyAt)
import Data.Foldable (fold)
import Data.Maybe (fromMaybe)
import Data.String (Pattern(..), split, joinWith, toUpper)
import Data.String.CodeUnits (take, drop)
import Data.String.CodeUnits (toCharArray, fromCharArray, singleton)
import Data.String.Unsafe (char)

capitalize :: String -> String
capitalize =
  split (Pattern " ")
    >>> map
      ( toCharArray
          >>> modifyAt 0 (singleton >>> toUpper >>> char)
          >>> fromMaybe []
          >>> fromCharArray
      )
    >>> joinWith " "

capitalizeFirst :: String -> String
capitalizeFirst s = toUpper (take 1 s) <> drop 1 s
