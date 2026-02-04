module Controller.DownloadController where

import Api.Request.Download (DownloadRequest(..), toFilePath)
import Control.Monad.Error.Class (catchError)
import Prelude
import Data.Maybe (Maybe(..), maybe)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (message)
import Node.Express.Handler (Handler)
import Node.Express.Request (getQueryParam)
import Node.Express.Response (download, defaultDownloadOptions, end, sendJson, setStatus)

downloadController :: Handler
downloadController = do
  mFilename <- getQueryParam "filename"
  mFiletype <- getQueryParam "filetype"
  maybe (badRequest mFilename mFiletype) respond (tupleToMaybe mFilename mFiletype)

tupleToMaybe :: Maybe String -> Maybe String -> Maybe DownloadRequest
tupleToMaybe (Just fn) (Just "gif") = Just (DownloadRequestGif fn)
tupleToMaybe (Just fn) (Just "video") = Just (DownloadRequestVideo fn)
tupleToMaybe (Just fn) (Just "mp3") = Just (DownloadRequestMp3 fn)
tupleToMaybe _ _ = Nothing

badRequest :: Maybe String -> Maybe String -> Handler
badRequest filename filetype = do
  liftEffect $ log ("Download: missing filename or filetype query params " <> show filename <> " - " <> show filetype)
  setStatus 400 *> sendJson { error: "Bad Request: filename and filetype query params required or invalid" } *> end

notFound :: String -> Handler
notFound filename = do
  liftEffect $ log ("Download: missing filename " <> show filename)
  setStatus 404 *> sendJson { error: "Not Found: filename is Missing" } *> end

checkFile :: DownloadRequest -> Handler
checkFile request = (liftEffect (void (toFilePath request))) `catchError` (\_ -> notFound (show request))

respond :: DownloadRequest -> Handler
respond request = do
  checkFile request
  filePath <- liftEffect (toFilePath request)
  download filePath defaultDownloadOptions (liftEffect <<< log <<< message)
  end

