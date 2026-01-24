module Controller.StatusController where

import Node.Express.Handler (Handler)
import Node.Express.Response (sendJson, setStatus)
import Response.StatusResponse (buildResponse)
import Model.ProcessStatus (ProcessStatus(Succeed))
import Prelude

statusController :: Handler
statusController = do
  let processStatus = Succeed
  setStatus 200 *> sendJson (buildResponse processStatus)
