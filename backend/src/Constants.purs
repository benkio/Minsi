module Constants where

import Effect (Effect)
import Prelude
import Node.Path (FilePath, resolve)
import Data.Traversable (traverse)

-- Single source of truth for the public/static root (change to "./public" for dist bundle)
publicDir :: FilePath
publicDir = "../public"

outputPath :: Effect FilePath
outputPath = resolve [] (publicDir <> "/output")

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

reversed :: String -> Effect FilePath
reversed filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> "_reversed.mp4")

reversedFull :: String -> Effect FilePath
reversedFull filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> "_reversed_full.mp4")

tempVideo :: String -> Effect FilePath
tempVideo filename = outputPath >>= (\tv -> resolve [ tv ] (filename <> "_temp.mp4"))

files :: String -> Effect (Array FilePath)
files filename =
  traverse (\f -> f filename)
    [ mp4
    , mp3
    , gif
    , srt
    , txt
    , reversed
    , reversedFull
    , tempVideo
    ]
