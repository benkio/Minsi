module Conversion.Time where

import Prelude

import Data.Array (dropWhile, tail, take, takeWhile)
import Data.Maybe (maybe)
import Data.String.CodeUnits (fromCharArray, toCharArray)

formatToMaxSixDigits :: Number -> String
formatToMaxSixDigits n =
  let
    chars = toCharArray (show n)
    digits = takeWhile (_ /= '.') chars
    millis = (maybe [] (take 3) <<< tail <<< dropWhile (_ /= '.')) chars
  in
    fromCharArray (digits <> millis)
