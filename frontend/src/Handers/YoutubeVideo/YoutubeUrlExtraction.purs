module Handers.YoutubeVideo.YoutubeUrlExtraction where

import Data.Array (head, last)
import Data.Array.NonEmpty (index)
import Data.Either (Either(..))
import Data.Int (fromString)
import Data.Map (lookup)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String (toLower)
import Data.String.Regex (regex, match)
import Data.String.Regex.Flags (noFlags)
import Data.URL (URL, Path(..), path, query)
import Control.Alt ((<|>))
import Prelude

extractYoutubeVideoId :: URL -> Maybe String
extractYoutubeVideoId url =
  maybeVQueryString <|> lastPath
  where
  maybeVQueryString = ((\v -> lookup "v" v >>= head) <<< query) url
  lastPath = (path >>> pathToArray >>> last) url

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
  case regex ("(\\d+)" <> unit) noFlags of
    Left _ -> 0
    Right r ->
      case join (match r str >>= ((flip index) 1)) of
        Just n -> fromMaybe 0 (fromString n)
        Nothing -> 0

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
