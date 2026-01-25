module Ffmpeg where

import Command.Command (runCommand)
import Constants (mp4)
import Data.Array (snoc)
import Data.Foldable (intercalate)
import Data.Int (floor)
import Data.Maybe (Maybe(..))
import Data.String.CodeUnits (singleton)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import MinsiError (MinsiError(..))
import Prelude
import Text.Printf (formatInt)
import Effect.Console (log)
import Node.Buffer as B
import Node.Encoding (Encoding(..))

secondsToString :: Int -> String
secondsToString seconds =
  intercalate ":" $ map (formatInt "02") [dd,hh,ss]
  where
    dd = seconds / 3600
    hh = (seconds `mod` 3600) / 60
    ss = (seconds `mod` 3600) `mod` 60

millisToString :: Milliseconds -> Char -> String
millisToString (Milliseconds ms) millisSeparator =
  secondsToString seconds <> singleton millisSeparator <> (formatInt "03" leftMillis)
  where
    seconds = (floor ms) / 1000
    leftMillis = (floor ms) `mod` 1000

millisecondsToSecondsString :: Milliseconds -> Maybe Char -> String
millisecondsToSecondsString ms Nothing = millisToString ms ','
millisecondsToSecondsString ms (Just c) = millisToString ms c

downloadVideo :: String -> String -> Milliseconds -> Milliseconds -> Effect Unit
downloadVideo videoSource filename start end = do
  f <- mp4 filename
  b <- runCommand (args `snoc` f) FfmpegVideoError "ffmpeg"
  s <- B.toString UTF8 b
  log s
  where
    startStr = millisecondsToSecondsString start (Just '.')
    endStr = millisecondsToSecondsString end (Just '.')
    args = [ "-hide_banner", "-loglevel", "warning", "-i", show videoSource, "-ss", startStr, "-to", endStr]

downloadMp3 :: Effect Unit
downloadMp3 = pure unit

makePlainGif :: Effect Unit
makePlainGif = pure unit
