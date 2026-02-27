module Endpoints.ResponseParser where

import Effect (Effect)

import Data.Either (either)
import Data.String (joinWith)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Fetch (Response)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude
import Yoga.JSON (class ReadForeign, readJSON)

validateResponse :: Response -> Effect Response
validateResponse response =
  if response.ok then pure response else throwMinsiError (ErrorResponse (response.status))

decodeJsonResponse :: forall a. ReadForeign a => String -> Response -> Aff a
decodeJsonResponse context response = do
  bodyText <- response.text
  decodeBody bodyText
  where
  decodeBody :: String -> Aff a
  decodeBody "" =
    liftEffect $ throwMinsiError (JSONParsingError (joinWith " " [ context, ": empty response body", "(http", show response.status, response.statusText, ")" ]))
  decodeBody b =
    either
      (\err -> liftEffect $ throwMinsiError (JSONParsingError (joinWith " " [ context, ":", show err, " (http ", show response.status, response.statusText, ")", " body=", b ])))
      pure
      (readJSON b)
