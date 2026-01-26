module Command.Ytdlp where

import Data.Tuple (Tuple(..))
import Constants (mp4)
import Data.Time.Duration (Milliseconds)
import Ffmpeg (millisecondsToSecondsString)
import Prelude
import Data.Maybe (Maybe(..))
import Data.Array (uncons)
import Control.Monad.Error.Class (catchError)
import Model.State (WURL(..))
import Data.URL (toString)
import MinsiError (MinsiError(..), throwMinsiError)
import Command.Command (runCommand)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Library.Execa (ExecaProcess, ExecaResult)

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

getYtdlpOutputUrl :: String -> WURL -> String -> String -> String -> Aff ExecaProcess
getYtdlpOutputUrl cookie (WURL url) filepath start end =
  runCommand args YtdlpError "yt-dlp"
  where
    urlString = toString url
    args = if cookie == "" then
        [ "-f", "\"best[ext=mp4]\"", "--download-sections", show ("*" <> start <> "-" <> end), "-o", show filepath, show urlString ]
      else
        [ "-f", "\"best[ext=mp4]\"", "--cookies-from-browser", cookie, "--download-sections", show ("*" <> start <> "-" <> end), "-o", show filepath, show urlString ]

downloadVideo :: WURL -> String -> Milliseconds -> Milliseconds -> Aff (Tuple ExecaProcess ExecaResult)
downloadVideo youtubeUri filename start end = do
  filepath <- liftEffect $ mp4 filename
  tryCookies ytdlpSupportedBrowserCookies youtubeUri filepath
  where
    startStr = millisecondsToSecondsString start (Just '.')
    endStr = millisecondsToSecondsString end (Just '.')
    tryCookies :: Array String -> WURL -> String -> Aff (Tuple ExecaProcess ExecaResult)
    tryCookies cookies url filepath =
      case uncons cookies of
        Just {head:c, tail:cs} ->
          catchError (getYtdlpOutputUrl c url filepath startStr endStr >>= (\p -> p.getResult <#> \r -> Tuple p r) ) (\_ -> tryCookies cs url filepath)
        Nothing -> liftEffect $ throwMinsiError (YtdlpError "All yt-dlp cookie attempts failed")
