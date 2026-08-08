module Parse.Font where

import Model.State.State (Color(..), Font(..), Position(..))

-- | Parses the combined font+color select value (e.g. "ImpactBlack", "ArialBlackYellow").
parseFontAndColor :: String -> { font :: Font, color :: Color }
parseFontAndColor "ImpactBlack" = { font: Impact, color: Black }
parseFontAndColor "ImpactWhite" = { font: Impact, color: White }
parseFontAndColor "ArialBlackYellow" = { font: ArialBlack, color: Yellow }
parseFontAndColor "ArialBlackLightGreen" = { font: ArialBlack, color: LightGreen }
parseFontAndColor "ArialBlackLightOrange" = { font: ArialBlack, color: LightOrange }
parseFontAndColor _ = { font: Impact, color: White }

parsePosition :: String -> Position
parsePosition "Top" = Top
parsePosition _ = Bottom

formatFontAndColor :: Font -> Color -> String
formatFontAndColor Impact Black = "ImpactBlack"
formatFontAndColor Impact White = "ImpactWhite"
formatFontAndColor ArialBlack Yellow = "ArialBlackYellow"
formatFontAndColor ArialBlack LightGreen = "ArialBlackLightGreen"
formatFontAndColor ArialBlack LightOrange = "ArialBlackLightOrange"
formatFontAndColor _ _ = "ImpactWhite"

formatPosition :: Position -> String
formatPosition Top = "Top"
formatPosition Bottom = "Bottom"
