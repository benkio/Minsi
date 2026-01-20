module Validations.YoutubeValidation where

import Prelude
import Effect (Effect)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (V(..), andThen)
import Data.String.Regex (Regex, regex)
import Data.String.Regex.Flags (noFlags)
import Data.Bifunctor (lmap)
import Node.URL (URL, new)
import Validations.RegexValidation (matches)

youtubeRegex :: String
youtubeRegex = """(http:|https:)?(\/\/)?(www\.)?(youtube.com|youtu.be)\/(watch|embed)?(\?v=|\/)?(\S+)?"""

youtubeRegexValidation :: V (Array String) Regex
youtubeRegexValidation = V $ lmap (\x -> [ x ]) (regex youtubeRegex noFlags)

youtubeUrlValidation :: String -> Effect (V (Array String) URL)
youtubeUrlValidation v =
  traverse new (andThen youtubeRegexValidation (\ytRegex -> matches ytRegex v))
