module Validations.LetterNumberUnderscoreValidation where

import Data.Bifunctor (lmap)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Model.ValidationErrors (ValidationErrors, fromSingleton)
import Prelude

-- | Only letters, numbers and underscores (no spaces).
letterNumberUnderscoreRegex :: String
letterNumberUnderscoreRegex = """^[a-zA-Z0-9_]+$"""

letterNumberUnderscoreRegexValidation :: String -> V ValidationErrors Regex
letterNumberUnderscoreRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex letterNumberUnderscoreRegex noFlags)

letterNumberUnderscoreValidation :: String -> String -> V ValidationErrors String
letterNumberUnderscoreValidation id v =
  andThen (letterNumberUnderscoreRegexValidation id)
    (\r -> if test r v then pure v else invalid (fromSingleton id "Only letters, numbers and underscores allowed (no spaces)"))
