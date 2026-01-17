module Controller.CutVideoController where

import Effect.Class (liftEffect)
import Effect.Console (log)
import Node.Express.Handler (Handler)
import Node.Express.Response (end, setResponseHeader, setStatus)
import Prelude (discard, (*>), ($))

cutVideoController :: Handler
cutVideoController = do
  setResponseHeader "Access-Control-Allow-Origin" "*"
  liftEffect $ log "cutVideo endpoint called"
  setStatus 200 *> end
