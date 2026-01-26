module Main.CheckDependencies where

import Prelude
import Data.Foldable (null)
import Effect.Aff (Aff)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Effect.Class (liftEffect)
import Endpoints.CheckDependencies (callCheckDependencies, MissingDependenciesResponse)

checkDependecies :: Aff Unit
checkDependecies = do
  { missedDependencies: deps } :: MissingDependenciesResponse <- callCheckDependencies
  if null deps then
    pure unit
  else
    liftEffect $ throwMinsiError $ MissingDependenciesError deps
