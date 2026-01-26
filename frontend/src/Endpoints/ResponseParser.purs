module Endpoints.ResponseParser where

import Effect (Effect)

import Data.Either (Either(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Fetch (Response)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Prelude
import Yoga.JSON (class ReadForeign, readJSON)

validateResponse :: Response -> Effect Response
validateResponse response =
  if response.ok then pure response else throwMinsiError (ErrorResponse (response.status))

decodeJsonResponse :: forall a. ReadForeign a => String -> Response -> Aff a
decodeJsonResponse context response = do
  bodyText <- response.text
  if bodyText == "" then
    liftEffect $
      throwMinsiError
        ( JSONParsingError
            ( context <> ": empty response body"
                <> " (http "
                <> show response.status
                <> " "
                <> response.statusText
                <> ")"
            )
        )
  else
    case (readJSON bodyText :: Either _ a) of
      Left err ->
        liftEffect $
          throwMinsiError
            ( JSONParsingError
                ( context <> ": " <> show err
                    <> " (http "
                    <> show response.status
                    <> " "
                    <> response.statusText
                    <> ")"
                    <> " body="
                    <> bodyText
                )
            )
      Right decoded ->
        pure decoded

