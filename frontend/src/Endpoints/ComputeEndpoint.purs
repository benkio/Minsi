module Endpoints.Compute where

import Data.Either (Either(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Fetch (Method(..), fetch)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Main.Config (backendUrl)
import Model.ProcessStatus (ProcessStatus)
import Model.State.State (State)
import Yoga.JSON (writeJSON, readJSON)
import Prelude

type ComputeResponse = { status :: ProcessStatus }

computeEndpoint :: String
computeEndpoint = backendUrl <> "compute"

callCompute :: State -> Aff ComputeResponse
callCompute state = do
  response <-
    fetch computeEndpoint
      { method: POST
      , body: writeJSON state
      , headers: { "Content-Type": "application/json" }
      }
  bodyText <- response.text
  when (bodyText == "") do
    liftEffect $
      throwMinsiError
        ( JSONParsingError
            ( "compute: empty response body"
                <> " (http " <> show response.status <> " " <> response.statusText <> ")"
            )
        )
  case (readJSON bodyText :: Either _ ComputeResponse) of
    Left err ->
      liftEffect $
        throwMinsiError
          ( JSONParsingError
              ( "compute: " <> show err
                  <> " (http " <> show response.status <> " " <> response.statusText <> ")"
                  <> " body=" <> bodyText
              )
          )
    Right decoded ->
      pure decoded
