module Controller.UploadController where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toMaybe)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Foreign (Foreign)
import InMemoryDB (Store)
import Node.Express.Handler (Handler, HandlerM(..))
import Node.Express.Request (getBody')
import Node.Express.Response (end, sendJson, setStatus)
import Node.Express.Types (Request)
import Yoga.JSON (unsafeStringify)

foreign import _getUploadedFile :: Request -> Nullable Foreign

-- | Get the uploaded file from the request (set by multer). Use after multer middleware.
getUploadedFile :: HandlerM (Maybe Foreign)
getUploadedFile = HandlerM \req _ _ -> pure $ toMaybe $ _getUploadedFile req

uploadController :: Store -> Handler
uploadController _store = do
  liftEffect $ log "[Upload Controller] Received a Request"
  bodyForeign <- getBody'
  liftEffect $ log $ "[Upload Controller] body (raw): " <> unsafeStringify bodyForeign
  fileMaybe <- getUploadedFile
  case fileMaybe of
    Just file -> do
      liftEffect $ log $ "[Upload Controller] uploaded file: " <> unsafeStringify file
      setStatus 200
      sendJson { received: true, message: "File uploaded" }
      end
    Nothing -> do
      liftEffect $ log "[Upload Controller] no file in request (expect multipart/form-data with field 'file')"
      setStatus 400
      sendJson { received: false, error: "No file in request" }
      end
