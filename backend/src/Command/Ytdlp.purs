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

getYtdlpOutputUrl :: String -> WURL -> String -> String -> String -> Aff ExecaProcess
getYtdlpOutputUrl cookie (WURL url) filepath start end =
  runCommand args YtdlpError "yt-dlp"
  where
  urlString = toString url
  args =
    if cookie == "" then
      [ "-f", "\"best[ext=mp4]\"", "--force-overwrite", "--download-sections", show ("*" <> start <> "-" <> end), "-o", show filepath, show urlString ]
    else
      [ "-f", "\"best[ext=mp4]\"", "--force-overwrite", "--download-sections", show ("*" <> start <> "-" <> end), "-o", show filepath, "--cookies-from-browser", cookie, show urlString ]

downloadOrCutVideo :: Source -> String -> Milliseconds -> Milliseconds -> Aff ExecaResult
downloadOrCutVideo LocalFile filename start end = do
  uploadedFilepath <- liftEffect $ validateAndResolveLocalFile filename
  finally (rm uploadedFilepath) (cutAndConvertUploadedVideo uploadedFilepath filename start end)
  where
  validateAndResolveLocalFile fn = do
    up <- uploaded fn
    fp <- mp4 fn
    unlessM (exists up) (throwMinsiError (FfmpegVideoError ("🚫 Error: Expected " <> show up <> " but not was found. Retry the `compute` and the upload")))
    log ("[Ytdlp] Cut " <> show up <> " To " <> show fp)
    pure up

downloadOrCutVideo (WebURL youtubeUri) filename start end = do
  filepath <- liftEffect do
    fp <- mp4 filename
    log ("[Ytdlp] Delete " <> show fp)
    pure fp
  apathize (rm filepath)
  tryCookies ytdlpSupportedBrowserCookies youtubeUri filepath
  where
  startStr = millisecondsToSecondsString start (Just '.')
  endStr = millisecondsToSecondsString end (Just '.')

  tryCookies :: Array String -> WURL -> String -> Aff ExecaResult
  tryCookies cookies url filepath =
    maybe
      (liftEffect $ throwMinsiError (YtdlpError "All yt-dlp cookie attempts failed"))
      ( \{ head: c, tail: cs } ->
          catchError
            ( getYtdlpOutputUrl c url filepath startStr endStr
                >>= _.getResult
                >>= \r -> case r.exit of
                  Normally 0 -> pure r
                  _ -> liftEffect $ throwMinsiError (YtdlpError r.message)
            )
            (\_ -> tryCookies cs url filepath)
      )
      (uncons cookies)

-- TODO: Implement
-- downloadFull :: Source -> Aff ExecaResult
-- downloadFull LocalFile = ???
-- downloadFull (WebURL youtubeUri) = ???
