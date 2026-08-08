module Validations.VideoUrlValidation where

import Data.Bifunctor (lmap)
import Data.Maybe (maybe)
import Data.String (joinWith)
import Data.String.Common (replaceAll)
import Data.String.Pattern (Pattern(..), Replacement(..))
import Data.String.Regex (Regex, regex, test)
import Data.URL (URL, fromString)
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Model.ValidationErrors (ValidationErrors, fromSingleton)
import Prelude
import Data.String.Regex.Flags (noFlags)
import Validations.RegexValidation (matches)

youtubeHostRegex :: String
youtubeHostRegex = """^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=([a-zA-Z0-9_-]+)|shorts\/([a-zA-Z0-9_-]+)|live\/([a-zA-Z0-9_-]+))|youtu\.be\/([a-zA-Z0-9_-]+))(?:[?&].*)?$"""

alternativeVideoHosts :: Array String
alternativeVideoHosts =
  [ "inv.nadeko.net"
  , "yewtu.be"
  , "invidious.nerdvpn.de"
  , "yt.chocolatemoo53.com"
  , "invidious.tiekoetter.com"
  , "invidious.f5.si"
  , "inv.zoomerville.com"
  , "ymusicapp.com"
  , "piped.video"
  ]

alternativeHostWatchRegex :: String
alternativeHostWatchRegex =
  let
    escapedHosts =
      map
        (replaceAll (Pattern ".") (Replacement "\\."))
        alternativeVideoHosts
  in
    "^(?:https?:\\/\\/)?(?:"
      <> joinWith "|" escapedHosts
      <> ")\\/+watch\\?v=([a-zA-Z0-9_-]+)(?:[?&].*)?$"

youtubeHostRegexValidation :: String -> V ValidationErrors Regex
youtubeHostRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex youtubeHostRegex noFlags)

alternativeHostWatchRegexValidation :: String -> V ValidationErrors Regex
alternativeHostWatchRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex alternativeHostWatchRegex noFlags)

matchesSupportedVideoHost :: String -> String -> V ValidationErrors String
matchesSupportedVideoHost id v =
  andThen
    (youtubeHostRegexValidation id)
    ( \ytRegex ->
        if test ytRegex v then pure v
        else
          andThen
            (alternativeHostWatchRegexValidation id)
            (\otherRegex -> matches otherRegex id v)
    )

videoUrlValidation :: String -> String -> V ValidationErrors URL
videoUrlValidation id v =
  lmap (\_ -> fromSingleton id "Invalid video URL") $
    andThen
      (matchesSupportedVideoHost id v)
      ( \urlString ->
          maybe
            (invalid (fromSingleton id "Error validating video URL"))
            pure
            (fromString urlString)
      )
