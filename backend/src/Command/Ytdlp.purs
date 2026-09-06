module Command.Ytdlp where

import Prelude

import Command.Command (runCommand)
import Constants (mp4)
import Control.Monad.Error.Class (catchError)
import Conversion.Time (millisecondsToSecondsString)
import Conversion.VideoUrlExtraction (toCanonicalYoutubeWatchUrl)
import Data.Array (uncons)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Time.Duration (Milliseconds(..))
import Data.Traversable (traverse)
import Data.URL (URL, toString)
import Effect.Aff (Aff, apathize, delay)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Node.ChildProcess.Types (Exit(..))
import Node.FS.Aff (rm)
import Node.Library.Execa (ExecaProcess, ExecaResult)
import Node.Process (lookupEnv)
import Node.Stream (errored)

newtype YtdlpInput = YtdlpInput
  { url :: URL
  , filename :: String
  , maybeStart :: Maybe Milliseconds
  , maybeEnd :: Maybe Milliseconds
  , streaming :: Boolean
  }

data YtdlpDownloadResult
  = YtdlpDownloadResult ExecaResult
  | YtdlpDownloadProcess ExecaProcess

data YtdlpCookieSource
  = NoCookies
  | BrowserCookies String
  | CookieFile String

ytdlpSupportedBrowserCookies :: Array String
ytdlpSupportedBrowserCookies =
  [ "chrome"
  , "chromium"
  , "firefox"
  , "brave"
  , "safari"
  , "edge"
  , "opera"
  , "vivaldi"
  , "whale"
  ]

ytdlpTimeout :: Maybe Milliseconds
ytdlpTimeout = Nothing

exportCookiesScriptUrl :: String
exportCookiesScriptUrl = "https://github.com/benkio/minsi/blob/main/start-minsi.sh"

startScriptRawUrl :: String
startScriptRawUrl = "https://raw.githubusercontent.com/benkio/minsi/main/start-minsi.sh"

getYtdlpOutputUrl :: YtdlpCookieSource -> YtdlpInput -> Aff ExecaProcess
getYtdlpOutputUrl cookieSource (YtdlpInput { url: url, filename: filename, maybeStart: maybeStart, maybeEnd: maybeEnd, streaming: streaming }) = do
  args <- liftEffect $ mp4 filename <#> buildArgs
  runCommand ytdlpTimeout args YtdlpError "yt-dlp"
  where
  urlString = toString (fromMaybe url (toCanonicalYoutubeWatchUrl url))
  maybeRangeArg = do
    start <- map (\start -> millisecondsToSecondsString start (Just '.')) maybeStart
    end <- map (\end -> millisecondsToSecondsString end (Just '.')) maybeEnd
    pure [ "--download-sections", show ("*" <> start <> "-" <> end) ]
  rangeArgs = maybe [] identity maybeRangeArg
  outputArgs filepath = if streaming then [ "-o", "-" ] else [ "-o", show filepath ]
  formatArgs =
    [ "-f"
    , "\"bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]\""
    , "--merge-output-format"
    , "mp4"
    , "--force-keyframes-at-cuts"
    , "--force-overwrite"
    , "--js-runtimes"
    , "node"
    ]
  inputArgs = case cookieSource of
    NoCookies -> [ show urlString ]
    BrowserCookies browser -> [ "--cookies-from-browser", browser, show urlString ]
    CookieFile cookiePath -> [ "--cookies", show cookiePath, show urlString ]
  buildArgs filepath = formatArgs <> rangeArgs <> outputArgs filepath <> inputArgs

ytdlpDownload :: YtdlpInput -> Aff YtdlpDownloadResult
ytdlpDownload input@(YtdlpInput { filename, streaming }) = do
  filepath <- liftEffect do
    fp <- mp4 filename
    log ("[Ytdlp] Delete " <> show fp)
    pure fp
  apathize (rm filepath)
  maybeCookieFile <- liftEffect $ lookupEnv "YTDLP_COOKIES_FILE"
  maybeYtDlpCookieFile <- liftEffect $ lookupEnv "YT_DLP_COOKIES_FILE"
  let
    cookieFileSource = case maybeCookieFile of
      Just cookieFile -> Just (CookieFile cookieFile)
      Nothing -> map CookieFile maybeYtDlpCookieFile
  let cookieSources = maybe [] (\source -> [ source ]) cookieFileSource <> [ NoCookies ] <> map BrowserCookies ytdlpSupportedBrowserCookies
  runtimeCookieSources <- traverse (prepareCookieSource filename) cookieSources
  tryCookies runtimeCookieSources
  where

  prepareCookieSource :: String -> YtdlpCookieSource -> Aff YtdlpCookieSource
  prepareCookieSource _ NoCookies = pure NoCookies
  prepareCookieSource _ (BrowserCookies browser) = pure (BrowserCookies browser)
  prepareCookieSource outputFilename (CookieFile cookiePath) = do
    let runtimeCookiePath = "/tmp/minsi-cookies-" <> outputFilename <> ".txt"
    apathize (rm runtimeCookiePath)
    cpResult <- runCommand ytdlpTimeout [ show cookiePath, show runtimeCookiePath ] YtdlpError "cp" >>= _.getResult
    case cpResult.exit of
      Normally 0 -> pure (CookieFile runtimeCookiePath)
      _ -> liftEffect $ throwMinsiError (YtdlpError cpResult.message)

  tryCookies :: Array YtdlpCookieSource -> Aff YtdlpDownloadResult
  tryCookies cookies =
    maybe
      ( liftEffect $ throwMinsiError
          ( YtdlpError
              ( "All yt-dlp cookie attempts failed."
                  <> "<br>"
                  <> "Download and run start-minsi.sh to export cookies and launch Docker with YTDLP_COOKIES_FILE."
                  <> "<br>"
                  <> "curl -fsSL "
                  <> startScriptRawUrl
                  <> " -o start-minsi.sh && chmod +x start-minsi.sh && ./start-minsi.sh"
                  <> "<br>"
                  <> exportCookiesScriptUrl
              )
          )
      )
      ( \{ head: c, tail: cs } ->
          catchError
            ( if streaming then streamingDownload c input
              else syncDownload c input
            )
            (\_ -> tryCookies cs)
      )
      (uncons cookies)

syncDownload :: YtdlpCookieSource -> YtdlpInput -> Aff YtdlpDownloadResult
syncDownload cookie input = do
  result <- getYtdlpOutputUrl cookie input >>= _.getResult
  case result.exit of
    Normally 0 -> pure $ YtdlpDownloadResult result
    _ -> liftEffect $ throwMinsiError (YtdlpError result.message)

streamingDownload :: YtdlpCookieSource -> YtdlpInput -> Aff YtdlpDownloadResult
streamingDownload cookie input = do
  process <- getYtdlpOutputUrl cookie input
  spawnedResult <- process.waitSpawned
  case spawnedResult of
    Left err -> liftEffect $ throwMinsiError (YtdlpError ("[Yt-dlp] 🚫 Stream spawned with Error: " <> show err))
    Right _ -> liftEffect $ log "[Yt-dlp] ✅ Stream spawned successfully"
  liftEffect $ log "[Yt-dlp] ⏳ Wait 1s to check stream health"
  delay (Milliseconds 1000.0)
  _ <-
    liftEffect $
      maybe
        (pure unit)
        ( \stdErr -> do
            isErrored <- errored stdErr.stream
            if isErrored then do
              throwMinsiError (YtdlpError ("[Yt-dlp] 🚫 Error Standard Output: errored"))
            else
              log "[Yt-dlp] ✅ Error Standard output not errored"
        )
        process.stderr
  liftEffect $
    maybe
      (throwMinsiError (YtdlpError "[Yt-dlp] 🚫 Missing stardard output stream for process"))
      (const $ log "[Yt-dlp] ✅ Process has a standard ouput stream")
      process.stdout
  pure $ YtdlpDownloadProcess process
