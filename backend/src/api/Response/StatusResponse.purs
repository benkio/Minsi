module Response.StatusResponse where

import Contracts.Api (StatusResponse)
import Domain.ProcessStatus (ProcessStatus(..))
import Prelude

buildResponse :: ProcessStatus -> StatusResponse
buildResponse (Failed e) = { status: "Failed", description: e }
buildResponse (LocalFileUploaded f) = { status: "LocalFileUploaded", description: f }
buildResponse status =
  { status: show status, description: "" }
