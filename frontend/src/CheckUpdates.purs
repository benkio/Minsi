module Main.CheckUpdates where

import Prelude

import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Components.HtmlIdAndClasses (updateRequiredModalId)
import Components.Modal (showBlockingModal)
import Endpoints.UpdateCheck (UpdateCheckResponse, callUpdateCheck)

checkUpdates :: Aff Unit
checkUpdates = do
  { updateAvailable } :: UpdateCheckResponse <- callUpdateCheck
  when updateAvailable (liftEffect (showBlockingModal updateRequiredModalId))
