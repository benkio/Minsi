module Validations.RegexValidation where

import Prelude
import Data.Validation.Semigroup (V, invalid)
import Data.String.Regex (Regex, test)
import Model.ValidationErrors (ValidationErrors, fromSingleton)

matches :: Regex -> String -> String -> V ValidationErrors String
matches r _ v | test r v = pure v
matches _ id v = invalid (fromSingleton id ("Invalid Input for regex: " <> v))
