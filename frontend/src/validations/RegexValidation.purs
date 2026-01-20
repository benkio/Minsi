module Validations.RegexValidation where

import Prelude
import Data.Validation.Semigroup (V(..), invalid)
import Data.String.Regex (Regex, test)

matches :: Regex -> String -> V (Array String) String
matches r v | test r v = pure v
matches r v = invalid [ "Input does not matches the requested format, value: " <> v <> " regex: " <> show r ]
