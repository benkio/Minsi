module Handers.YoutubeVideo.Handler where

import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Components.HtmlIds (resultPreviewId)
import Validations.YoutubeValidation (youtubeUrlValidation)
import Data.Foldable (foldl)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (invalid)
import Control.Alt ((<|>))
import Data.Map (lookup)
import Data.Maybe (Maybe, maybe)
import Data.URL (URL, Path(..), path, query)
import Prelude
import Effect (Effect)
import Web.DOM.Element (fromEventTarget)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI
import Web.Event.Event (target)
import Effect.Console (log)
import Handers.ErrorHandlers (genericErrorsHandler)
import Data.Array (head, last)

youtubeUrlEventListener :: Event -> Effect Unit
youtubeUrlEventListener ev = genericErrorsHandler $ do
  rawValue <- getInputValue ev
  let youtubeUrlV = maybe (invalid [ "Empty YoutubeUrl Input" ]) youtubeUrlValidation rawValue
  youtubeUrl <- foldl (\_ v -> pure v) (throwMinsiError (InvalidInput (show rawValue)))  youtubeUrlV
  videoId <- (maybe (throwMinsiError (InvalidInput (show rawValue))) pure <<< extractYoutubeVideoId) youtubeUrl
  let startTime = (lookup "t" <<< query) youtubeUrl
  log ("Youtube Url Handler fired with value: " <> show videoId <> " startTime: " <> show startTime)
  embedVideo { resultPreviewId: resultPreviewId, videoId: videoId, width: 1000, height: 500 }

getInputValue :: Event -> Effect (Maybe String)
getInputValue ev =
  traverse (HI.value) (target ev >>= fromEventTarget >>= HI.fromElement)

extractYoutubeVideoId :: URL -> Maybe String
extractYoutubeVideoId url =
  maybeVQueryString <|> lastPath
  where
    maybeVQueryString = ((\v -> lookup "v" v >>= head) <<< query) url
    lastPath = (path >>> pathToArray >>> last) url

pathToArray :: Path -> Array String
pathToArray PathEmpty        = []
pathToArray (PathAbsolute s) = s
pathToArray (PathRelative s) = s

type EmbedVideoConfig =
  {
    resultPreviewId :: String,
    videoId :: String,
    width :: Int,
    height :: Int
  }

foreign import embedVideo :: EmbedVideoConfig -> Effect Unit
