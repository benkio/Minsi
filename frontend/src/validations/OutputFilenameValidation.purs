module Validations.OutputFilenameValidation where

import Data.Bifunctor (lmap)
import Data.String (length)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Model.ValidationErrors (ValidationErrors, fromSingleton)
import Prelude

outputFilenameRegex :: String
outputFilenameRegex = """^[a-z]{1,5}_[A-Z][a-zA-Z0-9]*$"""

outputFilenameRegexValidation :: String -> V ValidationErrors Regex
outputFilenameRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex outputFilenameRegex noFlags)

outputFilenameValidation :: String -> String -> V ValidationErrors String
outputFilenameValidation id v =
  (outputFilenameRegexValidation id)
    `andThen`
      ( \r ->
          if test r v then pure v
          else invalid (fromSingleton id "Format must be: prefix_Name (1-5 lowercase letters, underscore, then capitalized letters/numbers)")
      )
    `andThen`
      ( \x ->
          if length x <= 50 then pure v
          else invalid (fromSingleton id ("Length must be max 50 chars. Got: " <> show (length x)))
      )
