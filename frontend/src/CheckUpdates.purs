module Main.CheckUpdates where

import Prelude

import Components.Modal (showModal, setBlockingModalBody, setBlockingModalAction)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Endpoints.UpdateCheck (UpdateCheckResponse, callUpdateCheck)

checkUpdates :: Aff Boolean
checkUpdates = do
  { updateAvailable, docsUrl, currentVersion, latestVersion } :: UpdateCheckResponse <- callUpdateCheck
  when updateAvailable $ liftEffect do
    log "Show the update blocking modal"
    setBlockingModalBody $
      if latestVersion == "unknown" then
        "Unable to verify the latest version right now. Please update Minsi to continue using the software. (current: " <> currentVersion <> ")"
      else
        "Your version of Minsi is out of date. Please update to the latest version to continue using the software. (current: " <> currentVersion <> ", latest: " <> latestVersion <> ")"
    setBlockingModalAction (Just { label: "How to update", href: docsUrl })
    showModal "blockingModal"

  pure updateAvailable
