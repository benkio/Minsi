module Model.ArtistPrefix where

import Data.Map (Map, lookup)
import Data.Map as Map
import Data.Maybe (Maybe)
import Data.String (trim)
import Data.Tuple (Tuple(..))

-- | Map of known artist names to the prefix enforced on the output filename.
artistPrefixMap :: Map String String
artistPrefixMap =
  Map.fromFoldable
    [ Tuple "Richard Philip Henry John Benson" "rphjb_"
    , Tuple "Omar Palermo" "ytai_"
    , Tuple "Xah Lee" "xah_"
    , Tuple "Alessandro Barbero" "abar_"
    , Tuple "Germano Mosconi" "mos_"
    ]

-- | Look up the output filename prefix for a known artist (trimmed input). Nothing if not in the map.
prefixForArtist :: String -> Maybe String
prefixForArtist s = lookup (trim s) artistPrefixMap
