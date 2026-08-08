module Validations.NonEmptyValidation where

import Prelude

import Data.Bifunctor (lmap)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Validation.Semigroup (V(..), andThen)
import Model.ValidationErrors (ValidationErrors, fromSingleton)
import Validations.RegexValidation (matches)

nonEmptyRegex :: String
nonEmptyRegex = """[\S\s]*\S[\S\s]*"""

nonEmptyRegexValidation :: String -> V ValidationErrors Regex
nonEmptyRegexValidation id =
  V $ lmap
    (\x -> fromSingleton id x)
    (regex nonEmptyRegex noFlags)

nonEmptyValidation :: String -> String -> V ValidationErrors String
nonEmptyValidation id v =
  lmap (\_ -> fromSingleton id "value cannot be empty") $
    andThen
      (nonEmptyRegexValidation id)
      (\r -> matches r id v)
