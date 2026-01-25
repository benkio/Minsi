module Main.MinsiErrors where

import Prelude
import Effect (Effect)
import Effect.Exception (error, throwException)
import Data.String (joinWith)
import Data.Map (Map, toUnfoldable)
import Data.Tuple (Tuple(..))

data MinsiError
  = HTMLElementNotFound String
  | MissingDependenciesError (Array String)
  | InvalidInput String String
  | InvalidInputs (Map String String)
  | JSONParsingError String
  | ErrorResponse Int

instance Show MinsiError where
  show = case _ of
    HTMLElementNotFound id ->
      "HTML Element couldn't be loaded: " <> id
    MissingDependenciesError deps ->
      "Dependency Error: <br>" <> joinWith "<br>" deps
    InvalidInput id v ->
      "[" <> id <> "] Invalid Input: " <> v
    InvalidInputs vs ->
      let errorMessages = map (\(Tuple k v) -> "[" <> k <> "] " <> v) (toUnfoldable vs)
      in joinWith "<br>" errorMessages
    JSONParsingError err -> "Error while parsing: " <> err
    ErrorResponse status -> "Got a Response with status ≠ 200: " <> show status

throwMinsiError :: forall a. MinsiError -> Effect a
throwMinsiError =
  throwException <<< error <<< show
