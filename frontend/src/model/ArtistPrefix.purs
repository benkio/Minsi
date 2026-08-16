module Model.ArtistPrefix where

import Data.Array (findMap, fromFoldable, sortBy)
import Data.Map (Map, lookup, values)
import Data.Map as Map
import Prelude
import Data.Maybe (Maybe)
import Data.String (length, trim)
import Data.String.CodeUnits (stripPrefix)
import Data.String.Pattern (Pattern(..))
import Data.Tuple (Tuple(..))

-- | Map of known artist names to the prefix enforced on the output filename.
artistPrefixMap :: Map String String
artistPrefixMap =
  Map.fromFoldable
    [ Tuple "Alessandro Barbero" "abar_"
    , Tuple "Alessandro Orlando" "orl_"
    , Tuple "Germano Mosconi" "mos_"
    , Tuple "Omar Palermo" "ytai_"
    , Tuple "Pino Scotto" "pino_"
    , Tuple "Richard Philip Henry John Benson" "rphjb_"
    , Tuple "Vittorio Sgarbi" "sgar_"
    , Tuple "Xah Lee" "xah_"
    ]

-- | Look up the output filename prefix for a known artist (trimmed input). Nothing if not in the map.
prefixForArtist :: String -> Maybe String
prefixForArtist s = lookup (trim s) artistPrefixMap

-- | If the string starts with a known prefix, return the prefix and the rest (longest match first).
findMatchingPrefix :: String -> Maybe { prefix :: String, rest :: String }
findMatchingPrefix s =
  findMap
    (\prefix -> map (\rest -> { prefix, rest }) (stripPrefix (Pattern prefix) s))
    (sortBy (flip (comparing length)) (fromFoldable (values artistPrefixMap)))
