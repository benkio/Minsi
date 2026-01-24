module Endpoints.Compute where

import Effect.Aff (Aff)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)
import Model.ProcessStatus (ProcessStatus)
import Model.State.State (State)
import Prelude
import Yoga.JSON (writeJSON)
import Endpoints.ResponseParser (decodeJsonResponse)

type ComputeResponse = { status :: ProcessStatus }

computeEndpoint :: String
computeEndpoint = backendUrl <> "compute"

callCompute :: State -> Aff ComputeResponse
callCompute state = do
  response <-
    fetch computeEndpoint
      { method: POST
      , body: writeJSON state
      , headers: { "Content-Type": "application/json" }
      }
  decodeJsonResponse "compute" response
