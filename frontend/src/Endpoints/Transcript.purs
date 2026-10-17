module Endpoints.Transcript where

import Prelude

import Contracts.Api (TranscriptResponse)
import Effect.Aff (Aff)
import Endpoints.ResponseParser (decodeJsonResponse)
import Fetch (Method(..), fetch)
import Main.Config (backendUrl)
import Yoga.JSON (writeJSON)

transcriptEndpoint :: String
transcriptEndpoint = backendUrl <> "transcript"

callTranscript :: String -> Aff TranscriptResponse
callTranscript filename = do
  response <- fetch transcriptEndpoint
    { method: POST
    , body: writeJSON { filename }
    , headers: { "Content-Type": "application/json" }
    }
  decodeJsonResponse "transcript" response
