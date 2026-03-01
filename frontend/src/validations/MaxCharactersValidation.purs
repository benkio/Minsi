module Validations.MaxCharatersValidation where

import Prelude

import Data.String (length)
import Data.Validation.Semigroup (V, invalid)
import Model.ValidationErrors (ValidationErrors, fromSingleton)

maxCharsValidation :: Int -> String -> String -> V ValidationErrors String
maxCharsValidation n id v
  | length v > n = invalid (fromSingleton id ("Invalid Input, max number of char exceded, got: " <> show (length v) <> " - max: " <> show n))
  | otherwise = pure v
