module Conversion.Filename where

import Prelude

import Data.Array (dropWhile, takeWhile)
import Data.String.CodeUnits (fromCharArray, toCharArray)

extractFileExt :: String -> String
extractFileExt = fromCharArray <<< dropWhile (_ /= '.') <<< toCharArray

extractBaseName :: String -> String
extractBaseName = fromCharArray <<< takeWhile (_ /= '.') <<< toCharArray

buildUploadedFilename :: String -> String -> String
buildUploadedFilename baseName fileExt = baseName <> "_uploaded" <> fileExt
