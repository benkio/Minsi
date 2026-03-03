module Response.StatusResponse where

import Model.ProcessStatus (ProcessStatus(..))
import Prelude

type StatusResponse = { status :: String, description :: String }

buildResponse :: ProcessStatus -> StatusResponse
buildResponse (Failed e) = { status: "Failed", description: e }
buildResponse (LocalFileUploaded f) = { status: "LocalFileUploaded", description: f }
buildResponse status =
  { status: show status, description: "" }
