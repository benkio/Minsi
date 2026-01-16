module Main.MinsiErrors where

import Prelude
import Effect (Effect)
import Effect.Exception (error, throwException)

data MinsiError
  = HTMLElementNotFound String
  | MissingDependenciesError (Array String)

instance Show MinsiError where
  show = case _ of
    HTMLElementNotFound id ->
      "HTML Element couldn't be loaded: " <> id
    MissingDependenciesError deps ->
      "Missing following dependencies: " <> show deps

throwMinsiError :: forall a. MinsiError -> Effect a
throwMinsiError =
  throwException <<< error <<< show
