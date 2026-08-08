module Validations.YoutubeValidation where

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

youtubeRegex :: String
youtubeRegex = """^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=([a-zA-Z0-9_-]+)|shorts\/([a-zA-Z0-9_-]+)|live\/([a-zA-Z0-9_-]+))|youtu\.be\/([a-zA-Z0-9_-]+))(?:[?&].*)?$"""

alternativeYoutubeHosts :: Array String
alternativeYoutubeHosts =
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

alternativeYoutubeWatchRegex :: String
alternativeYoutubeWatchRegex =
  let
    escapedHosts =
      map
        (replaceAll (Pattern ".") (Replacement "\\."))
        alternativeYoutubeHosts
  in
    "^(?:https?:\\/\\/)?(?:"
      <> joinWith "|" escapedHosts
      <> ")\\/+watch\\?v=([a-zA-Z0-9_-]+)(?:[?&].*)?$"

youtubeRegexValidation :: String -> V ValidationErrors Regex
youtubeRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex youtubeRegex noFlags)

alternativeYoutubeRegexValidation :: String -> V ValidationErrors Regex
alternativeYoutubeRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex alternativeYoutubeWatchRegex noFlags)

matchesYoutubeOrAlternative :: String -> String -> V ValidationErrors String
matchesYoutubeOrAlternative id v =
  andThen
    (youtubeRegexValidation id)
    ( \ytRegex ->
        if test ytRegex v then pure v
        else
          andThen
            (alternativeYoutubeRegexValidation id)
            (\otherRegex -> matches otherRegex id v)
    )

youtubeUrlValidation :: String -> String -> V ValidationErrors URL
youtubeUrlValidation id v =
  lmap (\_ -> fromSingleton id "Invalid Youtube URL") $
    andThen
      (matchesYoutubeOrAlternative id v)
      ( \urlString ->
          maybe
            (invalid (fromSingleton id "Error validating youtube Url"))
            pure
            (fromString urlString)
      )
