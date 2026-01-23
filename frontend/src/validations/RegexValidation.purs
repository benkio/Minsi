module Validations.RegexValidation where

import Data.Map (Map, singleton)
import Prelude
import Data.Validation.Semigroup (V, invalid)
import Data.String.Regex (Regex, test)

matches :: Regex -> String -> String -> V (Map String String) String
matches r _ v | test r v = pure v
matches _ id v = invalid (singleton id ("Invalid Input for regex: " <> v))
