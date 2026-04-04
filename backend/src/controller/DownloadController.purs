module Controller.DownloadController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store)
import Model.DownloadRequest (DownloadRequest)
import Model.State (Source(..), WURL(..))
import Data.URL (toString)
import Data.Validation.Semigroup (isValid)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (send, setAttachment)
import Validations.YoutubeValidation (youtubeUrlValidation)

downloadController :: Store -> Handler
downloadController _store = do
  bodyResult <- getBody
  case (runExcept bodyResult :: Either _ DownloadRequest) of
    Left errors -> downloadBadRequest errors
    Right { source: LocalFile} ->
      respondJsonPost "/download" 400 { error: "Bad Request: Expected URL, got LocalFile" }
    Right { source: WebURL (WURL url) } ->
      if isValid (youtubeUrlValidation "source" (toString url)) then do
        _ <- setAttachment "temp.txt"
        send ""
      else
        respondJsonPost "/download" 400 { error: "Bad Request: source must be a valid YouTube URL" }

downloadBadRequest :: forall a. Show a => a -> Handler
downloadBadRequest errors = do
  liftEffect $ log ("[Download Controller] Bad request body: " <> show errors)
  respondJsonPost "/download" 400 { error: "Bad Request: source required" }
