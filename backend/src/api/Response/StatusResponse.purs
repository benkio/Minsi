module Response.StatusResponse where

import Contracts.Api (StatusResponse)
import Domain.ProcessStatus (ProcessStatus(..))

buildResponse :: ProcessStatus -> StatusResponse
buildResponse (Failed e) = { status: "Failed", description: e }
buildResponse (LocalFileUploaded f) = { status: "LocalFileUploaded", description: f }
buildResponse Succeed = { status: "Succeed", description: "" }
buildResponse (Pending description) = { status: "Pending", description: description }
