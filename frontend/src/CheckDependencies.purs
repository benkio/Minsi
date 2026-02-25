module Main.CheckDependencies where

import Prelude
import Data.Foldable (null)
import Effect.Aff (Aff)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Effect.Class (liftEffect)
import Endpoints.CheckDependencies (callCheckDependencies, MissingDependenciesResponse)

checkDependecies :: Aff Unit
checkDependecies = do
  { missedDependencies: deps } :: MissingDependenciesResponse <- callCheckDependencies
  unless (null deps) (liftEffect $ throwMinsiError $ MissingDependenciesError deps)
