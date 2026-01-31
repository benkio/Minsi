module Parse.Font where

import Model.State.State (Font(..), Color(..), Position(..))

parseFont :: String -> Font
parseFont "Arial Black" = ArialBlack
parseFont _ = Impact

parseColor :: String -> Color
parseColor "Black" = Black
parseColor "Light Green" = LightGreen
parseColor "Light Orange" = LightOrange
parseColor "Yellow" = Yellow
parseColor _ = White

parsePosition :: String -> Position
parsePosition "Top" = Top
parsePosition _ = Bottom
