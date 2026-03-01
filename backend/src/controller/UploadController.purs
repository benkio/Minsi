module Controller.UploadController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Constants (rawOutput)
import Conversion.Filename (extractBaseName, extractFileExt, buildUploadedFilename)
import Effect (Effect)
import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (Nullable, toMaybe)
import Data.Tuple (Tuple(..), fst, snd)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store, insert)
import Model.ProcessStatus (ProcessStatus(..))
import Node.Buffer (Buffer)
import Node.Express.Handler (Handler, HandlerM(..))
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
  maybe noFileResponse (handleUpload store) fileBufferMaybe

noFileResponse :: Handler
noFileResponse = do
  liftEffect $ log "[Upload Controller] no file in request (expect multipart/form-data with field 'file')"
  respondJsonPost "/upload" 400 { received: false, error: "No file in request" }

handleUpload :: Store -> Tuple String Buffer -> Handler
handleUpload store fileAndBuffer = do
  liftEffect $ saveUploadedFile store fullFilename buffer
  respondJsonPost "/upload" 200 { received: true, message: "File uploaded" }
  where
  fullFilename = fst fileAndBuffer
  buffer = snd fileAndBuffer

saveUploadedFile :: Store -> String -> Buffer -> Effect Unit
saveUploadedFile store fullFilename buffer = do
  let
    fileExt = extractFileExt fullFilename
    filename = extractBaseName fullFilename
    uploadedFilename = buildUploadedFilename filename fileExt
  log $ "[Upload Controller] uploaded file " <> fullFilename
  outputFilename <- rawOutput uploadedFilename
  log $ "[Upload Controller] Write file to " <> outputFilename
  writeFile outputFilename buffer
  log $ "[Upload Controller] Save path to Db for: " <> filename
  insert filename Nothing (LocalFileUploaded outputFilename) store
