module Endpoints.Status where

import Effect.Aff (Aff)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)
import Prelude
import Endpoints.ResponseParser (decodeJsonResponse)

type StatusResponse = { status :: String }

statusEndpoint :: String
statusEndpoint = backendUrl <> "status"

callStatus :: Aff StatusResponse
callStatus = do
  response <- fetch statusEndpoint { method: POST }
  decodeJsonResponse "status" response
