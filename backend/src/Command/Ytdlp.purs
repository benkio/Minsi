module Command.Ytdlp where

import Prelude
import Effect (Effect)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Array (head, drop)
import Control.Monad.Error.Class (catchError)
import Effect.Exception (Error, error)
import Model.State (WURL(..))
import Data.URL (toString)
import Node.ChildProcess (spawnSync)
import Node.ChildProcess.Types (Exit(..))
import Node.Buffer (Buffer)

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

findYtpUrl :: WURL -> Effect (Either Error Buffer)
findYtpUrl youtubeUri = 
  case head ytdlpSupportedBrowserCookies of
    Nothing -> pure (Left (error "No browser cookies configured"))
    Just firstCookie -> do
      firstResult <- getYtdlpOutputUrl firstCookie youtubeUri
      case firstResult of
        Right buffer -> pure (Right buffer)
        Left _ -> tryRemainingCookies (drop 1 ytdlpSupportedBrowserCookies) youtubeUri
  where
    tryRemainingCookies :: Array String -> WURL -> Effect (Either Error Buffer)
    tryRemainingCookies [] _ = pure (Left (error "All yt-dlp cookie attempts failed"))
    tryRemainingCookies cookies url = 
      case head cookies of
        Nothing -> pure (Left (error "All yt-dlp cookie attempts failed"))
        Just cookie -> do
          result <- getYtdlpOutputUrl cookie url
          case result of
            Right buffer -> pure (Right buffer)
            Left _ -> tryRemainingCookies (drop 1 cookies) url
