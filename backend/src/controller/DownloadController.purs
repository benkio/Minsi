module Controller.DownloadController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Command.Ytdlp (YtdlpDownloadResult(..), YtdlpInput(..), ytdlpDownload)
import Control.Monad.Except (runExcept, runExceptT)
import Node.ChildProcess.Types (Exit(..))
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Nullable (toMaybe)
import Data.Newtype (unwrap)
import Data.URL (toString)
import Data.Validation.Semigroup (isValid)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Handlers.InputVideo.YoutubeUrlExtraction (extractYoutubeVideoId)
import InMemoryDB (Store)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Model.DownloadRequest (DownloadRequest)
import Model.State (Source(..), WURL(..))
import Node.Express.Handler (Handler, HandlerM(..), runHandlerM)
import Node.Express.Request (getBody)
import Node.Express.Types (Request, Response)
import Node.Express.Response (setAttachment, setStatus)
import Node.Library.Execa (ExecaProcess)
import Node.Stream as Stream
import Effect.Uncurried (mkEffectFn1, runEffectFn3)
import Unsafe.Coerce (unsafeCoerce)
import Validations.YoutubeValidation (youtubeUrlValidation)

downloadController :: Store -> Handler
downloadController _store = do
  bodyResult <- getBody
  let parseResult = lmap show (runExcept bodyResult) >>= validateDownloadBody
  case parseResult of
    Left err -> downloadBadRequest err
    Right downloadInfo -> handleDownload downloadInfo

handleDownload :: { url :: WURL, videoId :: String } -> Handler
handleDownload { url, videoId } =
  HandlerM \req resp _ -> do
    runResult <- liftAff $ runDownloadJob url videoId
    let runResponse :: Handler -> Aff Unit
        runResponse handler = runHandlerM' handler req resp
    case runResult of
      Left err -> do
        liftEffect $ log $ "[Download Controller] Download failed: " <> err
        runResponse $ respondJsonPost "/download" 500 { error: "Download failed: " <> err }
      Right process ->
        streamDownloadResult runResponse (videoId <> ".mp4") resp process

streamDownloadResult :: (Handler -> Aff Unit) -> String -> Response -> ExecaProcess -> Aff Unit
streamDownloadResult runResponse outputName resp process =
  maybe
    ( do
      liftEffect $ log "[Download Controller] Missing stdout stream for process."
      runResponse $ respondJsonPost "/download" 500 { error: "Download failed: missing process output stream" }
    )
    (\{ stream } -> do
      liftEffect $ log $ "[Download Controller] Set attachment " <> outputName <> " Set status 200"
      runResponse $ setAttachment outputName
      runResponse $ setStatus 200
      liftEffect $ log $ "[Download Controller] Send Stream"
      liftEffect $ Stream.pipe stream (unsafeCoerce resp)
      liftEffect $ log $ "[Download Controller] Get Result on process"
      result <- liftAff process.getResult
      let finalMessage = case result.exit of
            Normally 0 -> "[Download Controller] Stream finished: " <> outputName
            _ -> "[Download Controller] Stream ended with error: " <> result.message
      liftEffect $ log finalMessage
    )
    process.stdout

runHandlerM' :: Handler -> Request -> Response -> Aff Unit
runHandlerM' handler req resp =
  makeAff \done ->
    let nextFn = mkEffectFn1 \error ->
          case toMaybe error of
            Just err -> done (Left err)
            Nothing -> done (Right unit)
    in do
      runEffectFn3 (runHandlerM handler) req resp nextFn
      pure nonCanceler

runDownloadJob :: WURL -> String -> Aff (Either String ExecaProcess)
runDownloadJob (WURL url) filename =
  runExceptT do
    result <- liftAff $ ytdlpDownload (YtdlpInput { url: url, filename, maybeStart: Nothing, maybeEnd: Nothing, streaming: true })
    process <- case result of
      YtdlpDownloadResult _ -> liftEffect $ throwMinsiError $ YtdlpError "Streaming download, expected ExecaProcess"
      YtdlpDownloadProcess p -> pure p
    pure process

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
