module Command.Ytdlp where

import Prelude

import Command.Command (runCommand)
import Constants (mp4)
import Control.Monad.Error.Class (catchError)
import Conversion.Time (millisecondsToSecondsString)
import Data.Array (uncons)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)
import Data.Time.Duration (Milliseconds(..))
import Data.URL (URL, toString)
import Effect.Aff (Aff, apathize, delay)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Node.ChildProcess.Types (Exit(..))
import Node.FS.Aff (rm)
import Node.Library.Execa (ExecaProcess, ExecaResult)
import Node.Stream (errored)

newtype YtdlpInput = YtdlpInput
  { url :: URL
  , filename :: String
  , maybeStart :: Maybe Milliseconds
  , maybeEnd :: Maybe Milliseconds
  , streaming :: Boolean
  }

data YtdlpDownloadResult
  = YtdlpDownloadResult ExecaResult
  | YtdlpDownloadProcess ExecaProcess

ytdlpSupportedBrowserCookies :: Array String
ytdlpSupportedBrowserCookies =
  [ ""
  , "chrome"
  , "chromium"
  , "firefox"
  , "brave"
  , "safari"
  , "edge"
  , "opera"
  , "vivaldi"
  , "whale"
  ]

getYtdlpOutputUrl :: String -> YtdlpInput -> Aff ExecaProcess
getYtdlpOutputUrl cookie (YtdlpInput { url: url, filename: filename, maybeStart: maybeStart, maybeEnd: maybeEnd, streaming: streaming }) = do
  args <- liftEffect $ mp4 filename <#> buildArgs
  runCommand args YtdlpError "yt-dlp"
  where
  urlString = toString url
  maybeRangeArg = do
    start <- map (\start -> millisecondsToSecondsString start (Just '.')) maybeStart
    end <- map (\end -> millisecondsToSecondsString end (Just '.')) maybeEnd
    pure [ "--download-sections", show ("*" <> start <> "-" <> end) ]
  rangeArgs = maybe [] identity maybeRangeArg
  outputArgs filepath = if streaming then [ "-o", "-" ] else [ "-o", show filepath ]
  buildArgs filepath =
    if cookie == "" then
      [ "-f", "\"best[ext=mp4]\"", "--force-overwrite" ] <> rangeArgs <> outputArgs filepath <> [ show urlString ]
    else
      [ "-f", "\"best[ext=mp4]\"", "--force-overwrite" ] <> rangeArgs <> outputArgs filepath <> [ "--cookies-from-browser", cookie, show urlString ]

ytdlpDownload :: YtdlpInput -> Aff YtdlpDownloadResult
ytdlpDownload input@(YtdlpInput { filename, streaming }) = do
  filepath <- liftEffect do
    fp <- mp4 filename
    log ("[Ytdlp] Delete " <> show fp)
    pure fp
  apathize (rm filepath)
  tryCookies ytdlpSupportedBrowserCookies
  where

  tryCookies :: Array String -> Aff YtdlpDownloadResult
  tryCookies cookies =
    maybe
      (liftEffect $ throwMinsiError (YtdlpError "All yt-dlp cookie attempts failed"))
      ( \{ head: c, tail: cs } ->
          catchError
            ( if streaming then streamingDownload c input
              else syncDownload c input
            )
            (\_ -> tryCookies cs)
      )
      (uncons cookies)

syncDownload :: String -> YtdlpInput -> Aff YtdlpDownloadResult
syncDownload cookie input = do
  result <- getYtdlpOutputUrl cookie input >>= _.getResult
  case result.exit of
    Normally 0 -> pure $ YtdlpDownloadResult result
    _ -> liftEffect $ throwMinsiError (YtdlpError result.message)

streamingDownload :: String -> YtdlpInput -> Aff YtdlpDownloadResult
streamingDownload cookie input = do
  process <- getYtdlpOutputUrl cookie input
  spawnedResult <- process.waitSpawned
  case spawnedResult of
    Left err -> liftEffect $ throwMinsiError (YtdlpError ("[Yt-dlp] 🚫 Stream spawned with Error: " <> show err))
    Right _ -> liftEffect $ log "[Yt-dlp] ✅ Stream spawned successfully"
  liftEffect $ log "[Yt-dlp] ⏳ Wait 1s to check stream health"
  delay (Milliseconds 1000.0)
  _ <-
    liftEffect $
      maybe
        (pure unit)
        ( \stdErr -> do
            isErrored <- errored stdErr.stream
            if isErrored then do
              throwMinsiError (YtdlpError ("[Yt-dlp] 🚫 Error Standard Output: errored"))
            else
              log "[Yt-dlp] ✅ Error Standard output not errored"
        )
        process.stderr
  liftEffect $
    maybe
      (throwMinsiError (YtdlpError "[Yt-dlp] 🚫 Missing stardard output stream for process"))
      (const $ log "[Yt-dlp] ✅ Process has a standard ouput stream")
      process.stdout
  pure $ YtdlpDownloadProcess process
