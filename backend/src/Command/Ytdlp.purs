module Command.Ytdlp where

import Prelude

import Command.Command (runCommand)
import Constants (mp4)
import Control.Monad.Error.Class (catchError)
import Data.Array (uncons)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds)
import Data.URL (toString)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Conversion.Time (millisecondsToSecondsString)
import MinsiError (MinsiError(..), throwMinsiError)
import Model.State (WURL(..))
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

downloadVideo :: WURL -> String -> Milliseconds -> Milliseconds -> Aff ExecaResult
downloadVideo youtubeUri filename start end = do
  filepath <- liftEffect $ mp4 filename
  tryCookies ytdlpSupportedBrowserCookies youtubeUri filepath
  where
    startStr = millisecondsToSecondsString start (Just '.')
    endStr = millisecondsToSecondsString end (Just '.')

    tryCookies :: Array String -> WURL -> String -> Aff ExecaResult
    tryCookies cookies url filepath =
      case uncons cookies of
        Just { head: c, tail: cs } ->
          catchError (getYtdlpOutputUrl c url filepath startStr endStr >>= _.getResult) (\_ -> tryCookies cs url filepath)
        Nothing -> liftEffect $ throwMinsiError (YtdlpError "All yt-dlp cookie attempts failed")
