module Endpoints.CheckDependencies where

import Contracts.Api (CheckDependenciesResponse)
import Effect.Aff (Aff)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)
import Prelude
import Endpoints.ResponseParser (decodeJsonResponse)

checkDependeciesEndpoint :: String
checkDependeciesEndpoint = backendUrl <> "checkDependencies"

callCheckDependencies :: Aff CheckDependenciesResponse
callCheckDependencies = do
  response <- fetch checkDependeciesEndpoint { method: POST }
  if response.ok then
    pure { missedDependencies: [] }
  else do
    decodeJsonResponse "checkDependencies" response
