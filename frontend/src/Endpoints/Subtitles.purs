module Endpoints.Subtitles where

import Prelude

import Contracts.Api (WhisperSubtitlesResponse)
import Effect.Aff (Aff)
import Endpoints.ResponseParser (decodeJsonResponse)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)
import Yoga.JSON (writeJSON)

subtitlesEndpoint :: String
subtitlesEndpoint = backendUrl <> "subtitles"

callSubtitles :: String -> Aff WhisperSubtitlesResponse
callSubtitles filename = do
  response <- fetch subtitlesEndpoint
    { method: POST
    , body: writeJSON { filename }
    , headers: { "Content-Type": "application/json" }
    }
  decodeJsonResponse "subtitles" response

