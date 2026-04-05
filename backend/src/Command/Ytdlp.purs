module Command.Ytdlp where

import Prelude

import Command.Command (runCommand)
import Constants (mp4)
import Control.Monad.Error.Class (catchError)
import Conversion.Time (millisecondsToSecondsString)
import Data.Array (uncons)
import Data.Maybe (Maybe(..), maybe)
import Data.Time.Duration (Milliseconds)
import Data.URL (URL, toString)
import Effect.Aff (Aff, apathize)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Node.ChildProcess.Types (Exit(..))
import Node.FS.Aff (rm)
import Node.Library.Execa (ExecaProcess, ExecaResult)

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
getYtdlpOutputUrl cookie (YtdlpInput { url: url, filename: filename, maybeStart: maybeStart, maybeEnd: maybeEnd }) = do
  args <- liftEffect $ mp4 filename <#> buildArgs
  runCommand args YtdlpError "yt-dlp"
  where
  urlString = toString url
  maybeRangeArg = do
    start <- map (\start -> millisecondsToSecondsString start (Just '.')) maybeStart
    end <- map (\end -> millisecondsToSecondsString end (Just '.')) maybeEnd
    pure [ "--download-sections", show ("*" <> start <> "-" <> end) ]
  rangeArgs = maybe [] identity maybeRangeArg
  buildArgs filepath =
    if cookie == "" then
      [ "-f", "\"best[ext=mp4]\"", "--force-overwrite" ] <> rangeArgs <> [ "-o", show filepath, show urlString ]
    else
      [ "-f", "\"best[ext=mp4]\"", "--force-overwrite" ] <> rangeArgs <> [ "-o", show filepath, "--cookies-from-browser", cookie, show urlString ]

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
  pure $ YtdlpDownloadProcess process
