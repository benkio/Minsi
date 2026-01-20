module Validations.NonEmptyValidation where

import Prelude
import Data.Validation.Semigroup (V(..), andThen)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Bifunctor (lmap)
import Validations.RegexValidation (matches)

nonEmptyRegex :: String
nonEmptyRegex = """[\S\s]*\S[\S\s]*"""

nonEmptyRegexValidation :: V (Array String) Regex
nonEmptyRegexValidation = V $ lmap (\x -> [ x ]) (regex nonEmptyRegex noFlags)

nonEmptyValidation :: String -> V (Array String) String
nonEmptyValidation v =
  andThen nonEmptyRegexValidation (\r -> matches r v)
