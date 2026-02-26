module Validations.LetterNumberSpaceValidation where

import Data.Bifunctor (lmap)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Model.ValidationErrors (ValidationErrors, fromSingleton)
import Prelude

-- | Only letters, numbers and spaces (no spaces).
letterNumberSpaceRegex :: String
letterNumberSpaceRegex = """^[a-zA-Z0-9 ]+$"""

letterNumberSpaceRegexValidation :: String -> V ValidationErrors Regex
letterNumberSpaceRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex letterNumberSpaceRegex noFlags)

letterNumberSpaceValidation :: String -> String -> V ValidationErrors String
letterNumberSpaceValidation id v =
  andThen (letterNumberSpaceRegexValidation id)
    (\r -> if test r v then pure v else invalid (fromSingleton id "Only letters, numbers and spaces allowed"))
