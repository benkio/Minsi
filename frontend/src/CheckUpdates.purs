module Main.CheckUpdates where

import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Endpoints.UpdateCheck (UpdateCheckResponse, callUpdateCheck)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude

checkUpdates :: Aff Unit
checkUpdates = do
  { updateAvailable, currentVersion, latestVersion } :: UpdateCheckResponse <- callUpdateCheck
  when updateAvailable $ liftEffect $ throwMinsiError $ OutOfDateError currentVersion latestVersion
