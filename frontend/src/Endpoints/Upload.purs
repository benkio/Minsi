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
  formData <- liftEffect $ prepareUpload file filename
  response <- fetch uploadEndpoint
    { method: POST
    , body: formData
    }
  liftEffect do
    log "[Upload] Validate the response"
    void $ validateResponse response
  pure response.status
  where
  prepareUpload f fn = do
    log $ "[Upload] upload " <> fn
    log "[Upload] Create formData"
    fd <- fileToFormData f fn
    log "[Upload] FormData Created. Call the endpoint"
    pure fd
