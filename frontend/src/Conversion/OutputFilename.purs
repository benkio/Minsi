module Conversion.OutputFilename where

import Prelude
import Data.Maybe (Maybe(..))
import Conversion.String (capitalizeFirst)
import Model.ArtistPrefix (findMatchingPrefix)

-- | Normalize output filename: if it starts with a known prefix, capitalize only the part after the prefix; otherwise capitalize first character.
normalizeOutputFilename :: String -> String
normalizeOutputFilename s = case findMatchingPrefix s of
  Just { prefix, rest } -> prefix <> capitalizeFirst rest
  Nothing -> capitalizeFirst s
