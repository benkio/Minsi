module Endpoints.StatusPolling where

import Prelude

import Control.Monad.Rec.Class (Step(..), tailRecM)
import Data.Maybe (Maybe, fromMaybe)
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (Aff, delay)
import Effect.Class (liftEffect)
import Endpoints.Status (callStatus)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ProcessStatus (ProcessStatus)

waitForStatus :: String -> ProcessStatus -> Maybe (Int -> Aff Unit) -> Aff Unit
waitForStatus filename target maybeHandler = tailRecM pollStatus 0
  where
  handler = fromMaybe (\_ -> pure unit) maybeHandler
  pollStatus idx = do
    response <- callStatus filename
    case response.status of
      "Failed" -> liftEffect $ throwMinsiError (ComputeFailed ("Video download failed: " <> response.description))
      status | status == (show target) -> pure $ Done unit
      _ -> handler idx $> delay (Milliseconds 600.0) $> Loop (idx + 1)
