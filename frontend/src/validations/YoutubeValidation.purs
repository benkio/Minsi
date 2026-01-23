module Validations.YoutubeValidation where

import Data.Map (Map, singleton)
import Data.Maybe (maybe)
import Prelude
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Bifunctor (lmap)
import Data.URL (URL, fromString)
import Validations.RegexValidation (matches)

youtubeRegex :: String
youtubeRegex = """^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/watch\?v=([a-zA-Z0-9_-]+)|youtu\.be\/([a-zA-Z\d_-]+))(?:[?&].*)?$"""

youtubeRegexValidation :: String -> V (Map String String) Regex
youtubeRegexValidation id = V $ lmap (\x -> singleton id x) (regex youtubeRegex noFlags)

youtubeUrlValidation :: String -> String -> V (Map String String) URL
youtubeUrlValidation id v =
  lmap (\_ -> singleton id "Invalid Youtube URL") $
    andThen (
      andThen
        (youtubeRegexValidation id)
        (\ytRegex -> matches ytRegex id v)
      )
    (\urlString ->
      maybe
        (invalid (singleton id "Error validating youtube Url"))
        pure
        (fromString urlString)
    )
