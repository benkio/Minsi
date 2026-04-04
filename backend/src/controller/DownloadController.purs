module Controller.DownloadController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Data.Bifunctor (lmap)
import Data.Maybe (fromMaybe)
import Data.Newtype (unwrap)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store)
import Model.DownloadRequest (DownloadRequest)
import Model.State (Source(..), WURL)
import Handlers.InputVideo.YoutubeUrlExtraction (extractYoutubeVideoId)
import Data.URL (toString)
import Data.Validation.Semigroup (isValid)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (send, setAttachment)
import Validations.YoutubeValidation (youtubeUrlValidation)

downloadController :: Store -> Handler
downloadController _store = do
  bodyResult <- getBody
  let parseResult = lmap show (runExcept bodyResult) >>= validateDownloadBody
  either downloadBadRequest handleDownload parseResult

handleDownload :: { url :: WURL, videoId :: String } -> Handler
handleDownload _ =
  do
    filepath <- liftEffect $ mp4 videoId
    downloadOrCutVideo
    _ <- setAttachment filepath
    send ""

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
