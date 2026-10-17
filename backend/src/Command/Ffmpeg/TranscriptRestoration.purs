module Command.Ffmpeg.TranscriptRestoration where

import Prelude

import Config (punctuationServiceUrl)
import Control.Monad.Error.Class (catchError)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (error)

restoreTranscript :: String -> Aff String
restoreTranscript text = makeAff \done -> do
  serviceUrl <- punctuationServiceUrl
  _restoreTranscript serviceUrl text
    (\restored -> done (Right restored))
    (\err -> done (Left (error err)))
  pure nonCanceler

restoreTranscriptWithFallback :: String -> Aff String
restoreTranscriptWithFallback text =
  if text == "" then pure text
  else
    catchError
      (restoreTranscript text)
      (\err -> liftEffect (log ("[Transcription] Restoration fallback due to: " <> show err)) *> pure text)

foreign import _restoreTranscript :: String -> String -> (String -> Effect Unit) -> (String -> Effect Unit) -> Effect Unit
