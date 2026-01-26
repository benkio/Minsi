module Endpoints.Status where

import Prelude

import Effect.Aff (Aff)
import Endpoints.ResponseParser (decodeJsonResponse)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)
import Model.ProcessStatus (ProcessStatus)
import Yoga.JSON (writeJSON)

type StatusResponse = { status :: ProcessStatus }

statusEndpoint :: String
statusEndpoint = backendUrl <> "status"

callStatus :: String -> Aff StatusResponse
callStatus filename = do
  response <- fetch statusEndpoint
    { method: POST
    , body: writeJSON { filename }
    , headers: { "Content-Type": "application/json" }
    }
  decodeJsonResponse "status" response
