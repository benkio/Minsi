module Command.Ytdlp where

import Prelude

import Command.Command (runCommand)
import Command.Ffmpeg.Video (cutAndConvertUploadedVideo)
import Constants (mp4, uploaded)
import Control.Monad.Error.Class (catchError)
import Conversion.Time (millisecondsToSecondsString)
import Data.Array (uncons)
import Data.Maybe (Maybe(..), maybe)
import Data.Time.Duration (Milliseconds)
import Data.URL (toString)
import Effect.Aff (Aff, apathize, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State (Source(..), WURL(..))
import Node.ChildProcess.Types (Exit(..))
import Node.FS.Aff (rm)
import Node.FS.Sync (exists)
import Node.Library.Execa (ExecaProcess, ExecaResult)

newtype YtdlpInput = YtdlpInput
  { source :: Source
  , filename :: String
  , maybeStart :: Maybe Milliseconds
  , maybeEnd :: Maybe Milliseconds
  }

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
getYtdlpOutputUrl cookie (YtdlpInput { source: WebURL (WURL url), filename: filename, maybeStart: maybeStart, maybeEnd: maybeEnd }) = do
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
getYtdlpOutputUrl _ (YtdlpInput { source: LocalFile }) =
  liftEffect $ throwMinsiError (YtdlpError "Ytdlp not supported for local files")

downloadOrCutVideo :: YtdlpInput -> Aff ExecaResult
downloadOrCutVideo (YtdlpInput { source: LocalFile, filename, maybeStart, maybeEnd }) = do
  uploadedFilepath <- liftEffect $ validateAndResolveLocalFile filename
  finally (rm uploadedFilepath) (cutAndConvertUploadedVideo uploadedFilepath filename maybeStart maybeEnd)
  where
  validateAndResolveLocalFile fn = do
    up <- uploaded fn
    fp <- mp4 fn
    unlessM (exists up) (throwMinsiError (FfmpegVideoError ("🚫 Error: Expected " <> show up <> " but not was found. Retry the `compute` and the upload")))
    log ("[Ytdlp] Cut " <> show up <> " To " <> show fp)
    pure up

downloadOrCutVideo input@(YtdlpInput { filename }) = do
  filepath <- liftEffect do
    fp <- mp4 filename
    log ("[Ytdlp] Delete " <> show fp)
    pure fp
  apathize (rm filepath)
  tryCookies ytdlpSupportedBrowserCookies
  where

  tryCookies :: Array String -> Aff ExecaResult
  tryCookies cookies =
    maybe
      (liftEffect $ throwMinsiError (YtdlpError "All yt-dlp cookie attempts failed"))
      ( \{ head: c, tail: cs } ->
          catchError
            ( getYtdlpOutputUrl c input
                >>= _.getResult
                >>= \r -> case r.exit of
                  Normally 0 -> pure r
                  _ -> liftEffect $ throwMinsiError (YtdlpError r.message)
            )
            (\_ -> tryCookies cs)
      )
      (uncons cookies)
