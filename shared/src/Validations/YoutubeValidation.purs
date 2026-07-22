module Validations.YoutubeValidation where

import Data.Maybe (maybe)
import Prelude
import Data.Validation.Semigroup (V(..), andThen, invalid)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Bifunctor (lmap)
import Data.URL (URL, fromString)
import Model.ValidationErrors (ValidationErrors, fromSingleton)
import Validations.RegexValidation (matches)

youtubeRegex :: String
youtubeRegex = """^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=([a-zA-Z0-9_-]+)|shorts\/([a-zA-Z0-9_-]+)|live\/([a-zA-Z0-9_-]+))|youtu\.be\/([a-zA-Z0-9_-]+))(?:[?&].*)?$"""

youtubeRegexValidation :: String -> V ValidationErrors Regex
youtubeRegexValidation id = V $ lmap (\x -> fromSingleton id x) (regex youtubeRegex noFlags)

youtubeUrlValidation :: String -> String -> V ValidationErrors URL
youtubeUrlValidation id v =
  lmap (\_ -> fromSingleton id "Invalid Youtube URL") $
    andThen
      ( andThen
          (youtubeRegexValidation id)
          (\ytRegex -> matches ytRegex id v)
      )
      ( \urlString ->
          maybe
            (invalid (fromSingleton id "Error validating youtube Url"))
            pure
            (fromString urlString)
      )
