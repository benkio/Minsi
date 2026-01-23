module Validations.NonEmptyValidation where

import Prelude
import Data.Validation.Semigroup (V(..), andThen)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Bifunctor (lmap)
import Data.Map (Map, singleton)
import Validations.RegexValidation (matches)

nonEmptyRegex :: String
nonEmptyRegex = """[\S\s]*\S[\S\s]*"""

nonEmptyRegexValidation :: String -> V (Map String String) Regex
nonEmptyRegexValidation id =
  V $ lmap
        (\x -> singleton id x)
        (regex nonEmptyRegex noFlags)

nonEmptyValidation :: String -> String -> V (Map String String) String
nonEmptyValidation id v =
  lmap (\_ -> singleton id "value cannot be empty") $
    andThen
      (nonEmptyRegexValidation id)
      (\r -> matches r id v)
