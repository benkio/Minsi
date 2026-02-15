module Validations.OutputFilenameValidation where

import Conversion.String (capitalizeFirst)
import Data.Bifunctor (lmap)
import Data.Maybe (Maybe(..))
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Model.ArtistPrefix (findMatchingPrefix)
import Model.ValidationErrors (ValidationErrors, fromSingleton)
import Prelude

-- | Only letters, numbers and underscores (no spaces).
outputFilenameRegex :: String
outputFilenameRegex = """^[a-zA-Z0-9_]+$"""

outputFilenameRegexValidation :: String -> V ValidationErrors Regex
outputFilenameRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex outputFilenameRegex noFlags)

outputFilenameValidation :: String -> String -> V ValidationErrors String
outputFilenameValidation id v =
  andThen (outputFilenameRegexValidation id)
    (\r -> if test r v then pure v else invalid (fromSingleton id "Only letters, numbers and underscores allowed (no spaces)"))

-- | Normalize output filename: if it starts with a known prefix, capitalize only the part after the prefix; otherwise capitalize first character.
normalizeOutputFilename :: String -> String
normalizeOutputFilename s = case findMatchingPrefix s of
  Just { prefix, rest } -> prefix <> capitalizeFirst rest
  Nothing -> capitalizeFirst s
