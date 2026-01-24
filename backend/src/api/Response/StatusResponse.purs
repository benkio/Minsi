module Response.StatusResponse where

import Model.ProcessStatus (ProcessStatus)
import Prelude

type StatusResponse = { status :: String }

buildResponse :: ProcessStatus -> StatusResponse
buildResponse status =
  { status: show status }
