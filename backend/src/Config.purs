module Config where

import Data.Maybe (fromMaybe)
import Effect (Effect)
import Node.Process (lookupEnv)
import Prelude

-- | Must match the GitHub release tag format (e.g. "v1.2.3").
currentVersion :: String
currentVersion = "3.6"

punctuationServiceUrl :: Effect String
punctuationServiceUrl = fromMaybe "http://127.0.0.1:8090/restore" <$> lookupEnv "MINSI_PUNCTUATION_SERVICE_URL"
