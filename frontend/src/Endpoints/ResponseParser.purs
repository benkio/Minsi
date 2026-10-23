module Endpoints.ResponseParser where

import Data.Either (either)
import Data.String (joinWith)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Fetch (Response)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude
import Yoga.JSON (class ReadForeign, readJSON)

validateResponse :: Response -> Aff Response
validateResponse response =
  if response.ok
  then pure response
  else response.text
       >>= (\responseText -> liftEffect $ throwMinsiError (ErrorResponse response.status responseText))

decodeJsonResponse :: forall a. ReadForeign a => String -> Response -> Aff a
decodeJsonResponse context rawResponse = do
  response <- validateResponse rawResponse
  bodyText <- response.text
  decodeBody response bodyText
  where
  decodeBody :: Response -> String -> Aff a
  decodeBody response "" =
    liftEffect $
    throwMinsiError (
      JSONParsingError (
         joinWith " " [ context, ": empty response body", "(http", show response.status, response.statusText, ")" ]
         )
      )
  decodeBody response b =
    either
      (\err -> liftEffect $ throwMinsiError (JSONParsingError (joinWith " " [ context, ":", show err, " (http ", show response.status, response.statusText, ")", " body=", b ])))
      pure
      (readJSON b)
