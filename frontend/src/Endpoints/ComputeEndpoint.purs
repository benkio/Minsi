module Endpoints.Compute where

import Effect.Aff (Aff)
import Fetch (Method(..), fetch)
import Fetch.Yoga.Json (fromJSON)
import Main.Config (backendUrl)
import Model.ProcessStatus (ProcessStatus)
import Model.State.State (State)
import Prelude

type ComputeResponse = { status :: ProcessStatus }

computeEndpoint :: String
computeEndpoint = backendUrl <> "compute"

callCompute :: State -> Aff ComputeResponse
callCompute _state = do
  response <- fetch computeEndpoint { method: POST }
  decoded :: ComputeResponse <- fromJSON response.json
  pure decoded
