module Main.CheckDependencies where

import Prelude
import Effect.Aff (Aff)
import Main.Config (backendUrl)
import Fetch (fetch, Method(..))
import Fetch.Yoga.Json (fromJSON)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Foreign (Foreign)
import Effect.Class (liftEffect)

type MissingDependenciesResponse = { missedDependencies :: Array String }

checkDependeciesEndpoint :: String
checkDependeciesEndpoint = backendUrl <> "checkDependencies"

checkDependecies :: Aff Unit
checkDependecies = do
  response <- fetch checkDependeciesEndpoint { method: POST }
  if response.ok
  then pure unit
  else missingDependencies response.json

missingDependencies :: Aff Foreign -> Aff Unit
missingDependencies jsonText = do
  { missedDependencies: deps } :: MissingDependenciesResponse <- fromJSON jsonText
  liftEffect $ throwMinsiError $ MissingDependenciesError deps
