module Command.Ytdlp where

import Prelude
import Effect (Effect)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..))
import Data.Array (uncons)
import Control.Monad.Error.Class (catchError)
import Effect.Exception (Error, error)
import Model.State (WURL(..))
import Data.URL (toString)
import Node.ChildProcess (spawnSync)
import Node.ChildProcess.Types (Exit(..))
import Node.Buffer (Buffer)
import Node.Buffer as B
import Node.Encoding (Encoding(..))

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

getYtdlpOutputUrl :: String -> WURL -> Effect (Either Error Buffer)
getYtdlpOutputUrl cookie (WURL url) = do
  let urlString = toString url
  let args = if cookie == "" then
        [ "-f", "best[ext=mp4]", "-g", urlString ]
      else
        [ "-f", "best[ext=mp4]", "-g", "--cookies-from-browser", cookie, urlString ]
  catchError
    ( do
        result <- spawnSync "yt-dlp" args
        case result.exitStatus of
          Normally _ -> pure (Right result.stdout)
          _ -> pure (Left (error "yt-dlp command failed"))
    )
    ( \e -> pure (Left e)
    )

findYtpUrl :: WURL -> Effect (Either Error String)
findYtpUrl youtubeUri =
  tryCookies ytdlpSupportedBrowserCookies youtubeUri
  where
    tryCookies :: Array String -> WURL -> Effect (Either Error String)
    tryCookies cookies url =
      case uncons cookies of
        Just {head:c, tail:cs} -> either (\_ -> tryCookies cs url) (\b -> B.toString UTF8 b <#> Right) =<< (getYtdlpOutputUrl c url)
        Nothing -> pure (Left (error "All yt-dlp cookie attempts failed"))
