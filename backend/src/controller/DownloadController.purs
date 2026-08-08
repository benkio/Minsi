module Controller.DownloadController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Command.Ytdlp (YtdlpDownloadResult(..), YtdlpInput(..), ytdlpDownload)
import Data.Maybe (Maybe(..), maybe)
import Data.Either (Either(..))
import Data.Nullable (toMaybe)
import Data.URL (fromString)
import Data.Validation.Semigroup (isValid)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Effect.Exception (message)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Uncurried (mkEffectFn1, runEffectFn3)
import InMemoryDB (Store)
import Node.ChildProcess.Types (Exit(..))
import MinsiErrors (MinsiError(..), throwMinsiError)
import Node.Express.Handler (Handler, HandlerM(..), runHandlerM)
import Node.Express.Request (getRouteParam)
import Node.Express.Response (setAttachment, setStatus)
import Node.Express.Types (Request, Response)
import Node.Library.Execa (ExecaProcess)
import Node.Stream as Stream
import Unsafe.Coerce (unsafeCoerce)
import Validations.VideoUrlValidation (videoUrlValidation)
import Control.Monad.Error.Class (catchError)

downloadController :: Store -> Handler
downloadController _store = do
  maybeVideoId <- getRouteParam "videoId"
  maybe
    (downloadBadRequest "Bad Request: missing route param 'videoId'")
    handleDownload
    maybeVideoId

handleDownload :: String -> Handler
handleDownload videoId =
  HandlerM \req resp _ -> do
    runResult <- liftAff $ runDownloadJob videoId
    let
      runResponse :: Handler -> Aff Unit
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
    ( \{ stream } -> do
        liftEffect $ log $ "[Download Controller] Set attachment " <> outputName <> " Set status 200"
        runResponse $ setAttachment outputName
        runResponse $ setStatus 200
        liftEffect $ log $ "[Download Controller] Send Stream"
        liftEffect $ Stream.pipe stream (unsafeCoerce resp)
        liftEffect $ log $ "[Download Controller] Get Result on process"
        result <- liftAff process.getResult
        let
          finalMessage = case result.exit of
            Normally 0 -> "[Download Controller] Stream finished: " <> outputName
            _ -> "[Download Controller] Stream ended with error: " <> result.message
        liftEffect $ log finalMessage
    )
    process.stdout

runHandlerM' :: Handler -> Request -> Response -> Aff Unit
runHandlerM' handler req resp =
  makeAff \done ->
    let
      nextFn = mkEffectFn1 \error ->
        case toMaybe error of
          Just err -> done (Left err)
          Nothing -> done (Right unit)
    in
      do
        runEffectFn3 (runHandlerM handler) req resp nextFn
        pure nonCanceler

runDownloadJob :: String -> Aff (Either String ExecaProcess)
runDownloadJob id =
  catchError
    ( do
        let videoUrlString = "https://www.youtube.com/watch?v=" <> id
        if not (isValid (videoUrlValidation "videoId" videoUrlString)) then liftEffect $ throwMinsiError (InvalidInputError "Bad Request: source must be a valid supported video URL")
        else pure unit
        url <- maybe
          (liftEffect $ throwMinsiError (InvalidInputError ("[Download Controller] Can't build youtube url from id: " <> id)))
          pure
          (fromString videoUrlString)
        result <- ytdlpDownload (YtdlpInput { url, filename: id, maybeStart: Nothing, maybeEnd: Nothing, streaming: true })
        case result of
          YtdlpDownloadResult _ -> liftEffect $ throwMinsiError (YtdlpError "Streaming download, expected ExecaProcess")
          YtdlpDownloadProcess p -> pure (Right p)
    )
    (\err -> pure (Left $ message err))

downloadBadRequest :: String -> Handler
downloadBadRequest errorMessage = do
  liftEffect $ log ("[Download Controller] Bad request body: " <> errorMessage)
  respondJsonPost "/download" 400 { error: errorMessage }
