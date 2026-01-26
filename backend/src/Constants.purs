module Constants where

import Effect (Effect)
import Prelude
import Node.Path (FilePath, resolve)

outputPath :: Effect FilePath
outputPath = resolve [] "../public/output"

mp4 :: String -> Effect FilePath
mp4 filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> ".mp4")

mp3 :: String -> Effect FilePath
mp3 filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> ".mp3")

gif :: String -> Effect FilePath
gif filename = outputPath >>= \ofp -> resolve [ ofp ] (filename <> "Gif.mp4")
