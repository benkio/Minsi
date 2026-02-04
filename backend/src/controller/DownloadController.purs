module Controller.DownloadController where

import Prelude
import Data.Maybe (Maybe(..), maybe)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Node.Express.Handler (Handler)
import Node.Express.Request (getQueryParam)
import Node.Express.Response (sendJson, setStatus, end)

downloadController :: Handler
downloadController = do
  mFilename <- getQueryParam "filename"
  mFiletype <- getQueryParam "filetype"
  maybe badRequest respond (tupleToMaybe mFilename mFiletype)

tupleToMaybe :: forall a b. Maybe a -> Maybe b -> Maybe { filename :: a, filetype :: b }
tupleToMaybe (Just filename) (Just filetype) = Just { filename, filetype }
tupleToMaybe _ _ = Nothing

badRequest :: Handler
badRequest = do
  liftEffect $ log "Download: missing filename or filetype query params"
  setStatus 400 *> sendJson { error: "Bad Request: filename and filetype query params required" } *> end

respond :: { filename :: String, filetype :: String } -> Handler
respond _ = setStatus 200 *> end
