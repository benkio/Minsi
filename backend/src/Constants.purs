module Constants where

import Effect (Effect)
import Prelude
import Node.Path (FilePath, resolve)
import Data.Traversable (traverse)

outputPath :: Effect FilePath
outputPath = resolve [] "../public/output"

mp4 :: String -> Effect FilePath
mp4 filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> ".mp4")

mp3 :: String -> Effect FilePath
mp3 filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> ".mp3")

gif :: String -> Effect FilePath
gif filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> "Gif.mp4")

srt :: String -> Effect FilePath
srt filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> ".srt")

txt :: String -> Effect FilePath
txt filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> ".txt")

files :: String -> Effect (Array FilePath)
files filename =
  traverse (\f -> f filename) [
  mp4,
  mp3,
  gif,
  srt,
  txt
  ]
