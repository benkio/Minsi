module Validations.YoutubeValidation where

import Data.Maybe (maybe)
import Prelude
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Bifunctor (lmap)
import Data.URL (URL, fromString)
import Validations.RegexValidation (matches)

youtubeRegex :: String
youtubeRegex = """^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/watch\?v=([a-zA-Z0-9_]+)|youtu\.be\/([a-zA-Z\d_]+))(?:&.*)?$"""

youtubeRegexValidation :: V (Array String) Regex
youtubeRegexValidation = V $ lmap (\x -> [ x ]) (regex youtubeRegex noFlags)

youtubeUrlValidation :: String -> V (Array String) URL
youtubeUrlValidation v =
  andThen (andThen youtubeRegexValidation (\ytRegex -> matches ytRegex v)) \urlString ->
    maybe (invalid [ "Error validating youtube Url" ]) pure (fromString urlString)
