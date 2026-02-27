module Endpoints.StatusPolling where

import Prelude

import Control.Monad.Rec.Class (Step(..), tailRecM)
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (Aff, delay)
import Effect.Class (liftEffect)
import Endpoints.Status (callStatus)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ProcessStatus (ProcessStatus(..))

waitForStatus :: String -> ProcessStatus -> Aff Unit
waitForStatus filename target = tailRecM pollStatus unit
  where
  pollStatus _ = do
    response <- callStatus filename
    case response.status of
      (Failed error) -> liftEffect $ throwMinsiError (ComputeFailed ("Video download failed: " <> error))
      status | status == target -> pure $ Done unit
      _ -> delay (Milliseconds 500.0) $> Loop unit
