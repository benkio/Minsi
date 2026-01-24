module Endpoints.CheckDependencies where

import Data.Either (Either(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude
import Yoga.JSON (readJSON)

type MissingDependenciesResponse = { missedDependencies :: Array String }

checkDependeciesEndpoint :: String
checkDependeciesEndpoint = backendUrl <> "checkDependencies"

callCheckDependencies :: Aff MissingDependenciesResponse
callCheckDependencies = do
  response <- fetch checkDependeciesEndpoint { method: POST }
  if response.ok then
    pure { missedDependencies: [] }
  else do
    bodyText <- response.text
    case (readJSON bodyText :: Either _ MissingDependenciesResponse) of
      Left err ->
        liftEffect $ throwMinsiError (JSONParsingError ("checkDependencies: " <> show err <> " body=" <> bodyText))
      Right decoded ->
        pure decoded
