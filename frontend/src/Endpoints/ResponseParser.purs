module Endpoints.ResponseParser
  ( decodeJsonResponse
  ) where

import Data.Either (Either(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Fetch (Response)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude
import Yoga.JSON (class ReadForeign, readJSON)

-- Decode a JSON response body into `a`, raising a MinsiError on failure.
-- `context` is used to improve error messages (e.g. "compute", "checkDependencies").
decodeJsonResponse :: forall a. ReadForeign a => String -> Response -> Aff a
decodeJsonResponse context response = do
  bodyText <- response.text
  if bodyText == "" then
    liftEffect $
      throwMinsiError
        ( JSONParsingError
            ( context <> ": empty response body"
                <> " (http " <> show response.status <> " " <> response.statusText <> ")"
            )
        )
  else
    case (readJSON bodyText :: Either _ a) of
      Left err ->
        liftEffect $
          throwMinsiError
            ( JSONParsingError
                ( context <> ": " <> show err
                    <> " (http " <> show response.status <> " " <> response.statusText <> ")"
                    <> " body=" <> bodyText
                )
            )
      Right decoded ->
        pure decoded

