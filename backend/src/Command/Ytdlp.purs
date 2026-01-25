module Command.Ytdlp where

import Prelude
import Effect (Effect)
import Data.Maybe (Maybe(..))
import Data.Array (uncons)
import Control.Monad.Error.Class (catchError)
import Effect.Exception (message)
import Model.State (WURL(..))
import Data.URL (toString)
import Node.ChildProcess (spawnSync)
import Node.ChildProcess.Types (Exit(..))
import Node.Buffer (Buffer)
import Node.Buffer as B
import Node.Encoding (Encoding(..))
import MinsiError (MinsiError(..),throwMinsiError)
import Command.Command (runCommand)

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

getYtdlpOutputUrl :: String -> WURL -> Effect Buffer
getYtdlpOutputUrl cookie (WURL url) =
  runCommand args YtdlpError "yt-dlp"
  where
    urlString = toString url
    args = if cookie == "" then
        [ "-f", "best[ext=mp4]", "-g", urlString ]
      else
        [ "-f", "best[ext=mp4]", "-g", "--cookies-from-browser", cookie, urlString ]
--TODO: add local filepath as inputs
findYtpUrl :: WURL -> Effect String
findYtpUrl youtubeUri =
  tryCookies ytdlpSupportedBrowserCookies youtubeUri
  where
    tryCookies :: Array String -> WURL -> Effect String
    tryCookies cookies url =
      case uncons cookies of
        Just {head:c, tail:cs} ->
          catchError (getYtdlpOutputUrl c url >>= B.toString UTF8) (\_ -> tryCookies cs url)
        Nothing -> throwMinsiError (YtdlpError "All yt-dlp cookie attempts failed")
