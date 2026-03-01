module Endpoints.UpdateCheck where

import Prelude

import Effect.Aff (Aff)
import Endpoints.ResponseParser (decodeJsonResponse)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)

type UpdateCheckResponse =
  { updateAvailable :: Boolean
  , docsUrl :: String
  , currentVersion :: String
  , latestVersion :: String
  }

updateCheckEndpoint :: String
updateCheckEndpoint = backendUrl <> "updateCheck"

callUpdateCheck :: Aff UpdateCheckResponse
callUpdateCheck = do
  response <- fetch updateCheckEndpoint { method: POST }
  decodeJsonResponse "updateCheck" response

