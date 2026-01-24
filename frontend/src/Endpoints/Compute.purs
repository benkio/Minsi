module Endpoints.Compute where

import Effect.Class (liftEffect)

import Model.State.State (State(..))
import Endpoints.ResponseParser (validateResponse)
import Main.Config (backendUrl)
import Effect.Aff (Aff)
import Yoga.JSON (writeJSON)
import Endpoints.ResponseParser (decodeJsonResponse)
import Prelude
import Fetch (Response, fetch, Method(..))

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
  liftEffect $ validateResponse response
