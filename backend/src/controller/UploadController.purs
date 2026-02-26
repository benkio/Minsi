module Controller.UploadController where

import Prelude

import Constants (rawOutput)
import Data.Array (dropWhile, takeWhile)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toMaybe)
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Data.Tuple (Tuple(..))
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store, insert)
import Model.ProcessStatus (ProcessStatus(..))
import Node.Buffer (Buffer)
import Node.Express.Handler (Handler, HandlerM(..))
import Node.Express.Response (end, sendJson, setStatus)
import Node.Express.Types (Request)
import Node.FS.Sync (writeFile)

foreign import _getUploadedFileOriginalName :: Request -> Nullable String
foreign import _getUploadedFileBuffer :: Request -> Nullable Buffer

-- | Get the uploaded file from the request (set by multer). Use after multer middleware.
getUploadedFile :: HandlerM (Maybe (Tuple String Buffer))
getUploadedFile = HandlerM \req _ _ -> pure $ do
  originalName <- toMaybe $ _getUploadedFileOriginalName req
  buffer <- toMaybe $ _getUploadedFileBuffer req
  pure $ Tuple originalName buffer

uploadController :: Store -> Handler
uploadController store = do
  liftEffect $ log "[Upload Controller] Received a Request"
  fileBufferMaybe <- getUploadedFile
  case fileBufferMaybe of
    Just (Tuple fullFilename buffer) -> do
      -- TODO: validation on filename (check validation regex on frontend)
      let
        fileExt = fromCharArray $ dropWhile (_ /= '.') (toCharArray fullFilename)
        filename = fromCharArray $ takeWhile (_ /= '.') (toCharArray fullFilename)
        uploadedFilename = filename <> "_uploaded" <> fileExt
      liftEffect $ log $ "[Upload Controller] uploaded file " <> fullFilename
      outputFilename <- liftEffect $ rawOutput uploadedFilename
      liftEffect $ log $ "[Upload Controller] Write file to " <> outputFilename
      liftEffect $ writeFile outputFilename buffer
      liftEffect $ log $ "[Upload Controller] Save path to Db for: " <> filename
      liftEffect $ insert filename Nothing (LocalFileUploaded outputFilename) store
      setStatus 200
      sendJson { received: true, message: "File uploaded" }
      end
    Nothing -> do
      liftEffect $ log "[Upload Controller] no file in request (expect multipart/form-data with field 'file')"
      setStatus 400
      sendJson { received: false, error: "No file in request" }
      end
