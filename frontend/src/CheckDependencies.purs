module Main.CheckDependencies where

import Contracts.Api (CheckDependenciesResponse)
import Endpoints.CheckDependencies (callCheckDependencies)
import Prelude

import Data.Foldable (null)
import Effect.Aff (Aff)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Effect.Class (liftEffect)

checkDependecies :: Aff Unit
checkDependecies = do
  { missedDependencies: deps } :: CheckDependenciesResponse <- callCheckDependencies
  unless (null deps) (liftEffect $ throwMinsiError $ MissingDependenciesError deps)
