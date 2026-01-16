module Main.MinsiErrors where

import Prelude
import Control.Monad.Error.Class (class MonadThrow)
import Effect.Exception (throwException, error)
import Effect (Effect)

data MinsiError =
  HTMLElementNotFound String
  | MissingDependenciesError (Array String)

instance minsiError :: MonadThrow MinsiError Effect where
  throwError (HTMLElementNotFound id) = throwException $ error $ "HTML Element couldn't be loaded " <> id
  throwError (MissingDependenciesError deps) = throwException $ error $ "Missing Following dependencies: " <> (show deps)
