module Main.MinsiErrors where

import Prelude
import Effect (Effect)
import Effect.Exception (Error, errorWithName, throwException, name)
import Data.String (joinWith)
import Data.Map (Map, toUnfoldable)
import Data.Tuple (Tuple(..))

data ErrorSeverity
  = Fatal
  | Critical
  | Standard

data MinsiError
  = HTMLElementNotFound String
  | MissingDependenciesError (Array String)
  | OutOfDateError String String
  | InvalidInput String String
  | InvalidInputs (Map String String)
  | JSONParsingError String
  | ErrorResponse Int
  | ComputeFailed String

instance Show MinsiError where
  show = case _ of
    HTMLElementNotFound id ->
      "HTML Element couldn't be loaded: " <> id
    MissingDependenciesError deps ->
      "Dependency Error: <br>" <> joinWith "<br>" deps
    OutOfDateError current latest ->
      joinWith "<br>"
        [ "Minsi is out of date."
        , "Current Version: " <> current
        , "Latest Version: " <> latest
        , "Update at: https://github.com/benkio/minsi#updating-the-image"
        ]
    InvalidInput id v ->
      "[" <> id <> "] Invalid Input: " <> v
    InvalidInputs vs ->
      let
        errorMessages = map (\(Tuple k v) -> "[" <> k <> "] " <> v) (toUnfoldable vs)
      in
        joinWith "<br>" errorMessages
    JSONParsingError err -> "Error while parsing: " <> err
    ErrorResponse status -> "Got a Response with status ≠ 200: " <> show status
    ComputeFailed msg -> "Compute failed: " <> msg

throwMinsiError :: forall a. MinsiError -> Effect a
throwMinsiError =
  throwException <<< (const errorWithName <*> show <*> minsiErrorName)

minsiErrorName :: MinsiError -> String
minsiErrorName (HTMLElementNotFound _) = "HTMLElementNotFound"
minsiErrorName (MissingDependenciesError _) = "MissingDependenciesError"
minsiErrorName (InvalidInput _ _) = "InvalidInput"
minsiErrorName (InvalidInputs _) = "InvalidInputs"
minsiErrorName (JSONParsingError _) = "JSONParsingError"
minsiErrorName (ErrorResponse _) = "ErrorResponse"
minsiErrorName (ComputeFailed _) = "ComputeFailed"
minsiErrorName (OutOfDateError _ _) = "OutOfDateError"

getErrorSeverity :: Error -> ErrorSeverity
getErrorSeverity e = case name e of
  "HTMLElementNotFound" -> Critical
  "MissingDependenciesError" -> Fatal
  "OutOfDateError" -> Fatal
  "InvalidInput" -> Standard
  "InvalidInputs" -> Standard
  "JSONParsingError" -> Critical
  "ErrorResponse" -> Critical
  "ComputeFailed" -> Critical
  _ -> Standard
