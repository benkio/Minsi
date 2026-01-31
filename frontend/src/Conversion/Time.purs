module Conversion.Time where

import Prelude

import Data.Array (replicate, span, take, tail)
import Data.Maybe (maybe)
import Data.String.CodeUnits (fromCharArray, toCharArray)

formatToThreeDecimals :: Number -> String
formatToThreeDecimals v =
  let
    { init: i, rest: r } = span (\x -> x /= '.') <<< toCharArray $ show v
    num = fromCharArray i
    decChars = maybe [] identity (tail r)
    dec3 = take 3 (decChars <> replicate 3 '0')
    dec = fromCharArray dec3
  in
    num <> "." <> dec
