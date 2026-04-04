module Controller.DownloadController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Constants (outputPath)
import Model.State (Source)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (Error, message, try)
import InMemoryDB (Store)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (defaultDownloadOptions, download)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (writeTextFile)
import Node.Path (FilePath, resolve)

downloadController :: Store -> Handler
downloadController _store = do
  bodyResult <- getBody
  case (runExcept bodyResult :: Either _ Source) of
    Left errors -> downloadBadRequest errors
    Right _source -> do
      prepared <- liftEffect $ prepareDownloadFile
      case prepared of
        Left _ -> respondJsonPost "/download" 500 { error: "Failed to prepare temp file for download" }
        Right tempFilePath -> do
          download tempFilePath defaultDownloadOptions (downloadErrorHandler tempFilePath)

downloadBadRequest :: forall a. Show a => a -> Handler
downloadBadRequest errors = do
  liftEffect $ log ("[Download Controller] Bad request body: " <> show errors)
  respondJsonPost "/download" 400 { error: "Bad Request: source required" }

prepareDownloadFile :: Effect (Either String FilePath)
prepareDownloadFile = do
  output <- outputPath
  tempFile <- resolve [ output ] "temp.txt"
  result <- try (writeTextFile UTF8 tempFile "") :: Effect (Either Error Unit)
  pure $ case result of
    Left e -> Left (message e)
    Right _ -> Right tempFile

downloadErrorHandler :: FilePath -> Error -> Effect Unit
downloadErrorHandler filePath err =
  log $ "[Download Controller] Failed to send temp file: " <> filePath <> " (" <> message err <> ")"
