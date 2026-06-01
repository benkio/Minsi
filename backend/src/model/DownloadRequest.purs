module Model.DownloadRequest where

import Model.State.State (Source)

type DownloadRequest = { source :: Source }
