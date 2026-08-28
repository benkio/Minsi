module Contracts.Api where

import Model.State.State (Source, Subtitle)

type DownloadRequest = { source :: Source }

type StatusResponse = { status :: String, description :: String }

type WhisperSubtitlesResponse = { subtitles :: Array Subtitle }

type CheckDependenciesResponse = { missedDependencies :: Array String }

type UpdateCheckResponse =
  { updateAvailable :: Boolean
  , currentVersion :: String
  , latestVersion :: String
  }
