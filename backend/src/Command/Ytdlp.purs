module Command.Ytdlp where

import Prelude
import Model.State (WURL(..))
import Data.URL (toString)

ytdlpSupportedBrowserCookies :: Array String
ytdlpSupportedBrowserCookies = [
    "chrome",
    "chromium",
    "firefox",
    "brave",
    "safari",
    "edge",
    "opera",
    "vivaldi",
    "whale",
    ""
    ]

ytdlpCommand :: String -> WURL -> String
ytdlpCommand ""     (WURL url) = "yt-dlp -f best[ext=mp4] -g " <> toString url
ytdlpCommand cookie (WURL url) = "yt-dlp -f best[ext=mp4] -g --cookies-from-browser " <> cookie <> " " <> toString url

-- getDownloadableUri :: WURL -> ChildProcess
