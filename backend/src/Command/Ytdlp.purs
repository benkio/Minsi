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

getYtdlpOutputUrl :: String -> WURL -> String -> Maybe String -> Maybe String -> Aff ExecaProcess
getYtdlpOutputUrl cookie (WURL url) filepath maybeStart maybeEnd =
    runCommand args YtdlpError "yt-dlp"
  where
    urlString = toString url
    maybeRangeArg = do
      start <- maybeStart
      end <- maybeEnd
      pure [ "--download-sections", show ("*" <> start <> "-" <> end) ]
    rangeArgs = maybe [] identity maybeRangeArg
    args =
      if cookie == "" then
        [ "-f", "\"best[ext=mp4]\"", "--force-overwrite"] <> rangeArgs <> [ "-o", show filepath, show urlString ]
      else
        [ "-f", "\"best[ext=mp4]\"", "--force-overwrite"] <> rangeArgs <> [ "-o", show filepath, "--cookies-from-browser", cookie, show urlString ]

downloadOrCutVideo :: Source -> String -> Maybe Milliseconds -> Maybe Milliseconds -> Aff ExecaResult
downloadOrCutVideo LocalFile filename maybeStart maybeEnd = do
  uploadedFilepath <- liftEffect $ validateAndResolveLocalFile filename
  finally (rm uploadedFilepath) (cutAndConvertUploadedVideo uploadedFilepath filename maybeStart maybeEnd)
  where
  validateAndResolveLocalFile fn = do
    up <- uploaded fn
    fp <- mp4 fn
    unlessM (exists up) (throwMinsiError (FfmpegVideoError ("🚫 Error: Expected " <> show up <> " but not was found. Retry the `compute` and the upload")))
    log ("[Ytdlp] Cut " <> show up <> " To " <> show fp)
    pure up

downloadOrCutVideo (WebURL youtubeUri) filename maybeStart maybeEnd = do
  filepath <- liftEffect do
    fp <- mp4 filename
    log ("[Ytdlp] Delete " <> show fp)
    pure fp
  apathize (rm filepath)
  tryCookies ytdlpSupportedBrowserCookies youtubeUri filepath
  where
  maybeStartStr = millisecondsToSecondsString <$> maybeStart <*> pure (Just '.')
  maybeEndStr = millisecondsToSecondsString <$> maybeEnd <*> pure (Just '.')

  tryCookies :: Array String -> WURL -> String -> Aff ExecaResult
  tryCookies cookies url filepath =
    maybe
      (liftEffect $ throwMinsiError (YtdlpError "All yt-dlp cookie attempts failed"))
      ( \{ head: c, tail: cs } ->
          catchError
            ( getYtdlpOutputUrl c url filepath maybeStartStr maybeEndStr
                >>= _.getResult
                >>= \r -> case r.exit of
                  Normally 0 -> pure r
                  _ -> liftEffect $ throwMinsiError (YtdlpError r.message)
            )
            (\_ -> tryCookies cs url filepath)
      )
      (uncons cookies)
