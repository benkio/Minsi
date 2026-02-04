module Endpoints.DownloadAll where

import Prelude
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Endpoints.ResponseParser (validateResponse)
import Fetch (Response, Method(..), fetch)
import Main.Config (backendUrl)

downloadAllEndpoint :: String -> String
downloadAllEndpoint filename = backendUrl <> "downloadall?filename=" <> filename

callDownloadAll :: String -> Aff Response
callDownloadAll filename = do
  response <- fetch (downloadAllEndpoint filename) { method: GET }
  liftEffect $ validateResponse response
