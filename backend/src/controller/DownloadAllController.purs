module Controller.DownloadAllController where

import Prelude
import Data.Maybe (maybe)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Node.Express.Handler (Handler)
import Node.Express.Request (getQueryParam)
import Node.Express.Response (sendJson, setStatus, end)

downloadAllController :: Handler
downloadAllController = do
  mFilename <- getQueryParam "filename"
  maybe badRequest respond mFilename

badRequest :: Handler
badRequest = do
  liftEffect $ log "DownloadAll: missing filename query param"
  setStatus 400 *> sendJson { error: "Bad Request: filename query param required" } *> end

respond :: String -> Handler
respond _ = setStatus 200 *> end
