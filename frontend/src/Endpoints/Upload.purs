module Endpoints.Upload where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Endpoints.ResponseParser (validateResponse)
import Fetch (Method(..), fetch)
import Fetch.Internal.RequestBody (class ToRequestBody)
import JS.Fetch.RequestBody (RequestBody)
import Main.Config (backendUrl)
import Web.File.File (File)

foreign import data FormData :: Type

foreign import fileToFormData :: File -> String -> Effect FormData
foreign import formDataToRequestBody :: FormData -> RequestBody

instance ToRequestBody FormData where
  toRequestBody = formDataToRequestBody

uploadEndpoint :: String
uploadEndpoint = backendUrl <> "upload"

-- Replicates: FormData from file, then fetch POST with body formData
callUpload :: File -> String -> Aff Int
callUpload file filename = do
  formData <- liftEffect $ fileToFormData file filename
  response <- fetch uploadEndpoint
    { method: POST
    , body: formData
    }
  _ <- liftEffect $ validateResponse response
  pure response.status
