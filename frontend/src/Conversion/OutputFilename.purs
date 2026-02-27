module Conversion.OutputFilename where

import Prelude
import Data.Maybe (maybe)
import Conversion.String (capitalizeFirst)
import Model.ArtistPrefix (findMatchingPrefix)

-- | Normalize output filename: if it starts with a known prefix, capitalize only the part after the prefix; otherwise capitalize first character.
normalizeOutputFilename :: String -> String
normalizeOutputFilename s =
  maybe
    (capitalizeFirst s)
    (\{ prefix, rest } -> prefix <> capitalizeFirst rest)
    (findMatchingPrefix s)
