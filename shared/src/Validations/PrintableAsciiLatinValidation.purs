module Validations.PrintableAsciiLatinValidation where

import Data.Bifunctor (lmap)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Model.ValidationErrors (ValidationErrors, fromSingleton)
import Prelude

printableAsciiLatinRegex :: String
printableAsciiLatinRegex = """^[\x20-\x7E\u00C0-\u00FF ]+$"""

printableAsciiLatinRegexValidation :: String -> V ValidationErrors Regex
printableAsciiLatinRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex printableAsciiLatinRegex noFlags)

printableAsciiLatinValidation :: String -> String -> V ValidationErrors String
printableAsciiLatinValidation id v =
  andThen (printableAsciiLatinRegexValidation id)
    (\r -> if test r v then pure v else invalid (fromSingleton id ("Only printable ASCII and latin characters" <> v)))
