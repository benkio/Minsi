module Response.ComputeResponse where

import Model.ProcessStatus (ProcessStatus)
import Prelude

type ComputeResponse = { status :: String }

buildResponse :: ProcessStatus -> ComputeResponse
buildResponse status =
  { status: show status }
