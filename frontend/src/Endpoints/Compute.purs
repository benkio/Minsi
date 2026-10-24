module Endpoints.Compute where

import Effect.Aff (Aff)
import Endpoints.ResponseParser (validateResponse)
import Fetch (Response, fetch, Method(..))
import Main.Config (backendUrl)
import Model.State.State (State)
import Prelude
import Yoga.JSON (writeJSON)

computeEndpoint :: String
computeEndpoint = backendUrl <> "compute"

callCompute :: State -> Aff Response
callCompute state = do
  response <-
    fetch computeEndpoint
      { method: POST
      , body: writeJSON state
      , headers: { "Content-Type": "application/json" }
      }
  validateResponse response
