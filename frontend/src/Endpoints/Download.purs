module Endpoints.Download where

import Effect.Class (liftEffect)

import Endpoints.ResponseParser (validateResponse)
import Main.Config (backendUrl)
import Effect.Aff (Aff)
import Prelude
import Fetch (Response, fetch, Method(..))

downloadEndpoint :: String -> String -> String
downloadEndpoint filename filetype = backendUrl <> "download?filename="<>filename<>"&filetype="<>filetype

callDownload :: String -> String -> Aff Response
callDownload filename filetype = do
  response <- fetch (downloadEndpoint filename filetype) { method: GET }
  liftEffect $ validateResponse response
