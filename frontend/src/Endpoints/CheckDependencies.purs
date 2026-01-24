module Endpoints.CheckDependencies where

import Effect.Aff (Aff)
import Fetch (Method(..), fetch)
import Fetch.Yoga.Json (fromJSON)
import Main.Config (backendUrl)
import Prelude

type MissingDependenciesResponse = { missedDependencies :: Array String }

checkDependeciesEndpoint :: String
checkDependeciesEndpoint = backendUrl <> "checkDependencies"

callCheckDependencies :: Aff MissingDependenciesResponse
callCheckDependencies = do
  response <- fetch checkDependeciesEndpoint { method: POST }
  if response.ok then
    pure { missedDependencies: [] }
  else do
    decoded :: MissingDependenciesResponse <- fromJSON response.json
    pure decoded
