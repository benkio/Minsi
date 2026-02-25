module Model.State.State where

import Prelude
import Data.Newtype (class Newtype)
import Data.Time.Duration (Milliseconds(..))
import Data.URL (URL, toString)
import Node.Path (FilePath)
import Yoga.JSON (class WriteForeign, writeImpl)

-------------------------------------------------------------------------------
--                    Copy Pasted between Frontend↔Backend                   --
-------------------------------------------------------------------------------

newtype WURL = WURL URL
data Source = LocalFile | WebURL WURL

derive instance Eq WURL
derive instance Eq Source

newtype State = State
  { cutVideo :: DurationRange
  , source :: Source
  , filename :: FilePath
  , reverseLoop :: Boolean
  , uploadLocalFile :: Boolean
  , artist :: String
  , title :: String
  , subtitles :: Array Subtitle
  }

newtype DurationRange = DurationRange
  { start :: Milliseconds
  , end :: Milliseconds
  }

newtype Subtitle = Subtitle
  { videoPosition :: DurationRange
  , value :: String
  , font :: Font
  , fontSize :: Int
  , color :: Color
  , screenPosition :: Position
  }

data Font = Impact | ArialBlack
data Color = White | Black | LightGreen | LightOrange | Yellow
data Position = Top | Bottom

derive instance Eq Font
derive instance Eq Color
derive instance Eq Position
derive newtype instance eqDurationRange :: Eq DurationRange
derive newtype instance eqSubtitle :: Eq Subtitle

instance Show Font where
  show Impact = "Impact"
  show ArialBlack = "ArialBlack"

instance Show Color where
  show White = "White"
  show Black = "Black"
  show LightGreen = "LightGreen"
  show LightOrange = "LightOrange"
  show Yellow = "Yellow"

instance Show Position where
  show Top = "Top"
  show Bottom = "Bottom"

instance WriteForeign Position where
  writeImpl Top = writeImpl "Top"
  writeImpl Bottom = writeImpl "Bottom"

instance WriteForeign Color where
  writeImpl White = writeImpl "#ffffff"
  writeImpl Black = writeImpl "#000000"
  writeImpl LightGreen = writeImpl "#ABEBC6"
  writeImpl LightOrange = writeImpl "#FAD7A0"
  writeImpl Yellow = writeImpl "#FFFF00"

instance WriteForeign Font where
  writeImpl Impact = writeImpl "Impact"
  writeImpl ArialBlack = writeImpl "Arial Black"

derive newtype instance writeDurationRange :: WriteForeign DurationRange
derive newtype instance writeSubtitle :: WriteForeign Subtitle

instance WriteForeign WURL where
  writeImpl (WURL url) = writeImpl (toString url)

instance WriteForeign Source where
  writeImpl LocalFile = writeImpl "LocalFile"
  writeImpl (WebURL w) = writeImpl w

derive newtype instance writeState :: WriteForeign State
derive instance Newtype State _

instance Ord Subtitle where
  compare (Subtitle { videoPosition: (DurationRange { start: Milliseconds str1 }) }) (Subtitle { videoPosition: (DurationRange { start: Milliseconds str2 }) }) =
    compare str1 str2
