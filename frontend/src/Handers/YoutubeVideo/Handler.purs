module Handers.YoutubeVideo.Handler where

import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLSpanElement as HSP
import Effect.Class (liftEffect)
import Data.Time.Duration (Milliseconds(..))
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener)
import Control.Monad.Loops (whileM_)
import Data.Int (fromString)
import Data.String.Regex (regex, match)
import Data.String.Regex.Flags (noFlags)
import Data.Array.NonEmpty (index)
import Data.Either(Either(..))
import Data.String (toLower)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Components.HtmlIds (resultPreviewId)
import Validations.YoutubeValidation (youtubeUrlValidation)
import Data.Foldable (foldl)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (invalid)
import Control.Alt ((<|>))
import Data.Map (lookup)
import Data.Maybe (Maybe(..), maybe, fromMaybe)
import Data.URL (URL, Path(..), path, query)
import Prelude
import Effect (Effect)
import Effect.Timer (setInterval)
import Effect.Aff (delay, launchAff_)
import Web.DOM.Element (fromEventTarget)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI
import Web.Event.Event (target)
import Effect.Console (log)
import Handers.ErrorHandlers (genericErrorsHandler)
import Data.Array (head, last)
import Web.HTML.Event.EventTypes as E

setVideoHandlers :: HI.HTMLInputElement -> HSP.HTMLSpanElement -> HI.HTMLInputElement -> EventTarget -> Effect Unit
setVideoHandlers cutStart playbackPosition cutEnd ytUrlEventTarget = do
  ytEvL <- eventListener (youtubeUrlEventListener cutStart cutEnd)
  addEventListener E.input ytEvL false ytUrlEventTarget
  addEventListener E.change ytEvL false ytUrlEventTarget
  --TODO: fix, not updating.
  _ <- setInterval 1000 (updatePlaybackPosition playbackPosition)
  --TODO: Add the cut start position - cut end position handlers
  pure unit

youtubeUrlEventListener :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
youtubeUrlEventListener cutStart cutEnd ev = genericErrorsHandler $ do
  rawValue <- getInputValue ev
  let youtubeUrlV = maybe (invalid [ "Empty YoutubeUrl Input" ]) youtubeUrlValidation rawValue
  youtubeUrl <- foldl (\_ v -> pure v) (throwMinsiError (InvalidInput (show rawValue))) youtubeUrlV
  videoId <- (maybe (throwMinsiError (InvalidInput (show rawValue))) pure <<< extractYoutubeVideoId) youtubeUrl
  let startTime = extractYoutubeVideoStartTime youtubeUrl
  log ("Youtube Url Handler fired with value: " <> show videoId)
  embedVideo { resultPreviewId: resultPreviewId, videoId: videoId, width: 1000, height: 500, startTime: startTime}
  launchAff_ $ do
    whileM_ (pure (not (isPlayerReady unit))) (delay (Milliseconds 500.0))
    let duration = getVideoDuration unit
    liftEffect $ HI.setMax (show duration) cutStart
    liftEffect $ HI.setValue (show startTime) cutStart
    liftEffect $ HI.setMax (show duration) cutEnd

getInputValue :: Event -> Effect (Maybe String)
getInputValue ev =
  traverse (HI.value) (target ev >>= fromEventTarget >>= HI.fromElement)

--TODO: write tests
extractYoutubeVideoId :: URL -> Maybe String
extractYoutubeVideoId url =
  maybeVQueryString <|> lastPath
  where
  maybeVQueryString = ((\v -> lookup "v" v >>= head) <<< query) url
  lastPath = (path >>> pathToArray >>> last) url

--TODO: write tests
pathToArray :: Path -> Array String
pathToArray PathEmpty = []
pathToArray (PathAbsolute s) = s
pathToArray (PathRelative s) = s

type EmbedVideoConfig =
  { resultPreviewId :: String
  , videoId :: String
  , width :: Int
  , height :: Int
  , startTime :: Int
  }

foreign import embedVideo :: EmbedVideoConfig -> Effect Unit
foreign import getPlayerCurrentTime :: Unit -> Number
foreign import getVideoDuration :: Unit -> Number
foreign import isPlayerReady :: Unit -> Boolean

--TODO: write tests
extractYoutubeVideoStartTime :: URL -> Int
extractYoutubeVideoStartTime url = fromMaybe 0 $ do
  values <- (query >>> lookup "t") url
  v <- head values
  parseYouTubeT v

--TODO: write tests
parseUnit :: String -> String -> Int
parseUnit str unit =
  case regex ("(\\d+)" <> unit) noFlags of
    Left _ -> 0
    Right r ->
      case join (match r str >>= ((flip index) 1)) of
        Just n -> fromMaybe 0 (fromString n)
        Nothing -> 0

--TODO: write tests
parseYouTubeT :: String -> Maybe Int
parseYouTubeT raw =
  let
    str = toLower raw
  in
    -- plain seconds (e.g. "90")
    case fromString str of
      Just n -> Just n
      Nothing ->
        let
          h = parseUnit str "h"
          m = parseUnit str "m"
          s = parseUnit str "s"
          total = h * 3600 + m * 60 + s
        in
          if total > 0 then Just total else Nothing

updatePlaybackPosition :: HSP.HTMLSpanElement -> Effect Unit
updatePlaybackPosition playbackPosition = do
  log $ "updatePlayback position: " <> show playerReady
  when playerReady $ setTextContent currentTime (HSP.toNode playbackPosition)
  where
    playerReady = isPlayerReady unit
    currentTime = show $ getPlayerCurrentTime unit
