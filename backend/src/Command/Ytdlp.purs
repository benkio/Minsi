module Command.Ytdlp where

import Constants (mp4)
import Data.Time.Duration (Milliseconds)
import Ffmpeg (millisecondsToSecondsString)
import Prelude
import Effect (Effect)
import Data.Maybe (Maybe(..))
import Data.Array (uncons)
import Control.Monad.Error.Class (catchError)
import Model.State (WURL(..))
import Data.URL (toString)
import Node.Buffer (Buffer)
import MinsiError (MinsiError(..),throwMinsiError)
import Command.Command (runCommand)

ytdlpSupportedBrowserCookies :: Array String
ytdlpSupportedBrowserCookies = [
    "",
    "chrome",
    "chromium",
    "firefox",
    "brave",
    "safari",
    "edge",
    "opera",
    "vivaldi",
    "whale"
    ]

getYtdlpOutputUrl :: String -> WURL -> String -> String -> String -> Effect Buffer
getYtdlpOutputUrl cookie (WURL url) filepath start end =
  runCommand args YtdlpError "yt-dlp"
  where
    urlString = toString url
    args = if cookie == "" then
        [ "-f", "\"best[ext=mp4]\"", "--download-sections", show ("*" <> start <> "-" <> end), "-o", show filepath, show urlString ]
      else
        [ "-f", "\"best[ext=mp4]\"", "--cookies-from-browser", cookie, "--download-sections", show ("*" <> start <> "-" <> end), "-o", show filepath, show urlString ]

downloadVideo :: WURL -> String -> Milliseconds -> Milliseconds -> Effect Unit
downloadVideo youtubeUri filename start end = do
  filepath <- mp4 filename
  tryCookies ytdlpSupportedBrowserCookies youtubeUri filepath
  where
    startStr = millisecondsToSecondsString start (Just '.')
    endStr = millisecondsToSecondsString end (Just '.')
    tryCookies :: Array String -> WURL -> String -> Effect Unit
    tryCookies cookies url filepath =
      case uncons cookies of
        Just {head:c, tail:cs} ->
          catchError (void (getYtdlpOutputUrl c url filepath startStr endStr)) (\_ -> tryCookies cs url filepath)
        Nothing -> throwMinsiError (YtdlpError "All yt-dlp cookie attempts failed")
