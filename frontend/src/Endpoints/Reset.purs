module Endpoints.Reset where

import Prelude

import Effect.Aff (Aff)
import Endpoints.ResponseParser (validateResponse)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)

resetEndpoint :: String
resetEndpoint = backendUrl <> "reset"

callReset :: Aff Unit
callReset = do
  response <- fetch resetEndpoint { method: POST }
  void $ validateResponse response
