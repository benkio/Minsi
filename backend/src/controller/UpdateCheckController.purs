module Controller.UpdateCheckController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Config (currentVersion)
import Control.Monad.Except (ExceptT, runExceptT, throwError)
import Data.Array (head)
import Data.Either (Either(..), either)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Exception (message, try)
import InMemoryDB (Store)
import Node.Buffer (toString)
import Node.ChildProcess (execSync)
import Node.Encoding (Encoding(..))
import Node.Express.Handler (Handler)
import Yoga.JSON (readJSON)

type UpdateCheckResponse =
  { updateAvailable :: Boolean
  , currentVersion :: String
  , latestVersion :: String
  }

type GitHubTag = { name :: String }

fetchLatestGitHubTag :: Effect (Either String String)
fetchLatestGitHubTag = do
  r <- runExceptT fetch
  pure r
  where
  fetch :: ExceptT String Effect String
  fetch = do
    let url = "https://api.github.com/repos/benkio/minsi/tags"
    -- Synchronous call to keep dependencies minimal.
    -- GitHub API usually requires a User-Agent, so we set one.
    eBuf <- liftEffect $ try (execSync ("curl -sSL -H " <> show "User-Agent: minsi" <> " " <> show url))
    buf <- either (throwError <<< message) pure eBuf
    body <- liftEffect $ toString UTF8 buf
    let parsed = readJSON body :: Either _ (Array GitHubTag)
    either
      (\err -> throwError ("Failed to parse GitHub tags JSON: " <> show err <> " body=" <> body))
      (\tags -> maybe (throwError "No tags found from GitHub API") (pure <<< _.name) (head tags))
      parsed

updateCheckController :: Store -> Handler
updateCheckController _store = do
  eLatest <- liftEffect fetchLatestGitHubTag
  case eLatest of
    Left _err -> do
      respondJsonPost "/updateCheck" 200
        ( { updateAvailable: false
          , currentVersion
          , latestVersion: "unknown"
          } :: UpdateCheckResponse
        )
    Right latestVersion -> do
      let updateAvailable = latestVersion /= currentVersion
      respondJsonPost "/updateCheck" 200
        ( { updateAvailable
          , currentVersion
          , latestVersion
          } :: UpdateCheckResponse
        )
