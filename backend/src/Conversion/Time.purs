module Conversion.Time where

import Prelude

import Data.Array (replicate, span, take, tail)
import Data.Foldable (intercalate)
import Data.Int (floor)
import Data.Maybe (Maybe(..), maybe)
import Data.String.CodeUnits (fromCharArray, singleton, toCharArray)
import Data.Time.Duration (Milliseconds(..))
import Text.Printf (formatInt)

secondsToString :: Int -> String
secondsToString seconds =
  intercalate ":" $ map (formatInt "02") [ dd, hh, ss ]
  where
  dd = seconds `div` 3600
  hh = (seconds `mod` 3600) `div` 60
  ss = (seconds `mod` 3600) `mod` 60

millisToString :: Milliseconds -> Char -> String
millisToString (Milliseconds ms) millisSeparator =
  secondsToString seconds <> singleton millisSeparator <> (formatInt "03" leftMillis)
  where
  seconds = (floor ms) `div` 1000
  leftMillis = (floor ms) `mod` 1000

millisecondsToSecondsString :: Milliseconds -> Maybe Char -> String
millisecondsToSecondsString ms Nothing = millisToString ms ','
millisecondsToSecondsString ms (Just c) = millisToString ms c

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
