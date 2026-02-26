module Endpoints.Upload where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Endpoints.ResponseParser (validateResponse)
import Fetch (Method(..), fetch)
import Fetch.Internal.RequestBody (class ToRequestBody)
import JS.Fetch.RequestBody (RequestBody)
import Main.Config (backendUrl)
import Web.File.File (File)

foreign import data FormData :: Type

-- FFI returns a 0-arg function (Effect FormData). Do not change to sync + pure: the
-- compiler may then pass the FormData into Sync and the runtime will throw.
foreign import fileToFormData :: File -> String -> Effect FormData

foreign import formDataToRequestBody :: FormData -> RequestBody

instance ToRequestBody FormData where
  toRequestBody = formDataToRequestBody

uploadEndpoint :: String
uploadEndpoint = backendUrl <> "upload"

-- Replicates: FormData from file, then fetch POST with body formData
callUpload :: File -> String -> Aff Int
callUpload file filename = do
  liftEffect $ log $ "[Upload] upload " <> filename
  liftEffect $ log $ "[Upload] Create formData"
  formData <- liftEffect $ fileToFormData file filename
  liftEffect $ log $ "[Upload] FormData Created. Call the endpoint"
  response <- fetch uploadEndpoint
    { method: POST
    , body: formData
    }
  liftEffect $ log $ "[Upload] Validate the response"
  _ <- liftEffect $ validateResponse response
  pure response.status
