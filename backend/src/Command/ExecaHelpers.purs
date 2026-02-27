module Command.ExecaHelpers where

import Prelude

import Control.Monad.Error.Class (catchError)
import Control.Monad.Except (ExceptT(..), lift)
import Data.Either (Either(..))
import Data.Traversable (traverse_)
import Effect.Aff (Aff)
import Effect.Exception (message)
import Node.ChildProcess.Types (Exit(..))
import Node.Library.Execa (ExecaResult)

isSuccessExit :: Exit -> Boolean
isSuccessExit (Normally 0) = true
isSuccessExit _ = false

execaResultToEither :: String -> ExecaResult -> Either String Unit
execaResultToEither label r =
  if isSuccessExit r.exit then Right unit else Left (label <> " failed. Command: " <> r.escapedCommand <> " - stderr: " <> r.stderr)

checkExecaResult :: String -> ExecaResult -> ExceptT String Aff Unit
checkExecaResult label r = ExceptT $ pure $ execaResultToEither label r

exceptTStep :: String -> Aff ExecaResult -> ExceptT String Aff Unit
exceptTStep label aff =
  ExceptT $
    (aff >>= \r -> pure $ execaResultToEither label r)
      `catchError` (\e -> pure $ Left (label <> ": " <> message e))

exceptTMultiple :: String -> Aff (Array ExecaResult) -> ExceptT String Aff Unit
exceptTMultiple label affs = do
  steps <- lift affs
  traverse_ (checkExecaResult label) steps
