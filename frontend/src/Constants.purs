module Constants where

import Prelude

outputPath :: String
outputPath = "/output/"

mp4 :: String -> String
mp4 filename = outputPath <> filename <> ".mp4"

mp3 :: String -> String
mp3 filename = outputPath <> filename <> ".mp3"

gif :: String -> String
gif filename = outputPath <> filename <> "Gif.mp4"

fromType :: String -> String -> String
fromType "gif" = gif
fromType "mp3" = mp3
fromType "mp4" = mp4
fromType _ = mp4

