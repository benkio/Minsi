module Response.ComputeResponse where

import Model.ProcessStatus (ProcessStatus)

type ComputeResponse = { status :: ProcessStatus }

buildResponse :: ProcessStatus -> ComputeResponse
buildResponse status =
  { status: status }
