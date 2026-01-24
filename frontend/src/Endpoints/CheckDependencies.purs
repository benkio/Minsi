module Endpoints.CheckDependencies where

import Effect.Aff (Aff)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)
import Prelude
import Endpoints.ResponseParser (decodeJsonResponse)

type MissingDependenciesResponse = { missedDependencies :: Array String }

checkDependeciesEndpoint :: String
checkDependeciesEndpoint = backendUrl <> "checkDependencies"

callCheckDependencies :: Aff MissingDependenciesResponse
callCheckDependencies = do
  response <- fetch checkDependeciesEndpoint { method: POST }
  if response.ok then
    pure { missedDependencies: [] }
  else do
    decodeJsonResponse "checkDependencies" response
