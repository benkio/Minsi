module Controller.DownloadController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Constants (outputPath)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (Error, message, try)
import InMemoryDB (Store)
import Model.DownloadRequest (DownloadRequest)
import Model.State (Source(..), WURL(..))
import Node.Encoding (Encoding(..))
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (send, setAttachment)
import Node.FS.Sync (writeTextFile)
import Node.Path (FilePath, resolve)

downloadController :: Store -> Handler
downloadController _store = do
  bodyResult <- getBody
  case (runExcept bodyResult :: Either _ DownloadRequest) of
    Left errors -> downloadBadRequest errors
    Right { source: (WebURL (WURL _url))} -> do
      _ <- setAttachment "temp.txt"
      send ""
    Right { source: LocalFile} -> respondJsonPost "/download" 400 { error: "Bad Request: Expected URL, got LocalFile" }

downloadBadRequest :: forall a. Show a => a -> Handler
downloadBadRequest errors = do
  liftEffect $ log ("[Download Controller] Bad request body: " <> show errors)
  respondJsonPost "/download" 400 { error: "Bad Request: source required" }
