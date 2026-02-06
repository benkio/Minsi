module HTMLInputElement where

import Data.Validation.Semigroup (V)
import Effect (Effect)
import Model.ValidationErrors (ValidationErrors)
import Prelude
import Validations.NonEmptyValidation (nonEmptyValidation)
import Web.HTML.HTMLInputElement (HTMLInputElement, value)

nonEmptyFromHtmlInput :: HTMLInputElement -> String -> Effect (V ValidationErrors String)
nonEmptyFromHtmlInput i id =
  value i <#> nonEmptyValidation id
