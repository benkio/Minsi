module Controller.DownloadController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Command.ExecaHelpers (exceptTStep)
import Command.Ytdlp (YtdlpInput(..), downloadOrCutVideo)
import Constants (mp4)
import Control.Monad.Except (runExcept, runExceptT)
import Data.Bifunctor (lmap)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (unwrap)
import Data.URL (toString)
import Data.Validation.Semigroup (isValid)
import Effect.Aff (Aff, Milliseconds(..), delay)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Handlers.InputVideo.YoutubeUrlExtraction (extractYoutubeVideoId)
import InMemoryDB (Store)
import Model.DownloadRequest (DownloadRequest)
import Model.State (Source(..), WURL)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (downloadExt, defaultDownloadOptions, headersSent)
import Node.Express.Types (DownloadFileName(..))
import Node.FS.Sync (exists)
import Validations.YoutubeValidation (youtubeUrlValidation)

downloadController :: Store -> Handler
downloadController _store = do
  bodyResult <- getBody
  let parseResult = lmap show (runExcept bodyResult) >>= validateDownloadBody
  either downloadBadRequest handleDownload parseResult

handleDownload :: { url :: WURL, videoId :: String } -> Handler
handleDownload { url, videoId } = do
  filepath <- liftEffect $ mp4 videoId
  runResult <- liftAff (runDownloadJob (WebURL url) videoId)
  case runResult of
    Left err -> do
      liftEffect $ log ("[Download Controller] Download failed: " <> err)
      respondJsonPost "/download" 500 { error: "Download failed: " <> err }
    Right _ -> do
      liftAff $ delay (Milliseconds 500.0)
      fileReady <- liftEffect $ exists filepath
      if fileReady then do
        liftEffect $ log $ "[Download Controller] Sending back: " <> filepath
        headersAlreadySent <- headersSent
        liftEffect $ log $ "[Download Controller] headersSent before download: " <> show headersAlreadySent
        downloadExt filepath (DownloadFileName (videoId <> ".mp4")) defaultDownloadOptions
          (\err -> log ("[Download controller] Download file transfer failed: " <> show err))
        headersAfterDownload <- headersSent
        liftEffect $ log $ "[Download Controller] headersSent after download call: " <> show headersAfterDownload
        when (not headersAfterDownload) do
          liftAff $ delay (Milliseconds 800.0)
          headersAfterWait <- headersSent
          liftEffect $ log $ "[Download Controller] headersSent after wait: " <> show headersAfterWait
      else
        respondJsonPost "/download" 404 { error: "Downloaded file not found: " <> filepath }

runDownloadJob :: Source -> String -> Aff (Either String Unit)
runDownloadJob source filename =
  runExceptT $ exceptTStep "Video download" $ downloadOrCutVideo (YtdlpInput { source, filename, maybeStart: Nothing, maybeEnd: Nothing })

validateDownloadBody :: DownloadRequest -> Either String { url :: WURL, videoId :: String }
validateDownloadBody request = do
  videoUrl <- getWebURL request
  let maybeVideoId = fromMaybe "" $ extractYoutubeVideoId (unwrap videoUrl)
  if isValid (youtubeUrlValidation "source" (toString (unwrap videoUrl))) && maybeVideoId /= "" then
    pure { url: videoUrl, videoId: maybeVideoId }
  else
    Left "Bad Request: source must be a valid YouTube URL"

getWebURL :: DownloadRequest -> Either String WURL
getWebURL request = sourceToWURL request.source

sourceToWURL :: Source -> Either String WURL
sourceToWURL LocalFile = Left "Bad Request: Expected URL, got LocalFile"
sourceToWURL (WebURL url) = Right url

downloadBadRequest :: String -> Handler
downloadBadRequest errorMessage = do
  liftEffect $ log ("[Download Controller] Bad request body: " <> errorMessage)
  respondJsonPost "/download" 400 { error: errorMessage }
