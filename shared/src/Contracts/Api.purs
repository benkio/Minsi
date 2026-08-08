module Contracts.Api where

import Model.State.State (Source)

type DownloadRequest = { source :: Source }

type StatusResponse = { status :: String, description :: String }

type CheckDependenciesResponse = { missedDependencies :: Array String }

type UpdateCheckResponse =
  { updateAvailable :: Boolean
  , currentVersion :: String
  , latestVersion :: String
  }
