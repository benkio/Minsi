module Conversion.YoutubeUrlExtraction where

import Data.Array (head, last)
import Data.Array.NonEmpty (index)
import Data.Either (either)
import Data.Int (fromString) as Int
import Data.Map (lookup)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.String (toLower)
import Data.String.Regex (regex, match)
import Data.String.Regex.Flags (noFlags)
import Data.URL (URL, Path(..), fromString, path, query)
import Control.Alt ((<|>))
import Prelude

extractYoutubeVideoId :: URL -> Maybe String
extractYoutubeVideoId url =
  maybeVQueryString <|> lastPath
  where
  maybeVQueryString = ((\v -> lookup "v" v >>= head) <<< query) url
  lastPath = (path >>> pathToArray >>> last) url

-- | Canonical watch URL for yt-dlp (avoids /live/ hang-stream manifests).
toYoutubeWatchUrl :: URL -> Maybe URL
toYoutubeWatchUrl url = do
  videoId <- extractYoutubeVideoId url
  fromString ("https://www.youtube.com/watch?v=" <> videoId)

pathToArray :: Path -> Array String
pathToArray PathEmpty = []
pathToArray (PathAbsolute s) = s
pathToArray (PathRelative s) = s

extractYoutubeVideoStartTime :: URL -> Int
extractYoutubeVideoStartTime url = fromMaybe 0 $ do
  values <- (query >>> lookup "t") url
  v <- head values
  parseYouTubeT v

parseUnit :: String -> String -> Int
parseUnit str unit =
  either (const 0)
    (\r -> fromMaybe 0 (join (match r str >>= (flip index 1)) >>= Int.fromString))
    (regex ("(\\d+)" <> unit) noFlags)

parseYouTubeT :: String -> Maybe Int
parseYouTubeT raw =
  let
    str = toLower raw
  in
    maybe (parseDuration str) Just (Int.fromString str)
  where
  parseDuration str =
    let
      h = parseUnit str "h"
      m = parseUnit str "m"
      s = parseUnit str "s"
      total = h * 3600 + m * 60 + s
    in
      if total > 0 then Just total else Nothing
