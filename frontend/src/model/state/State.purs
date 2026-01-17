module Model.State.State where

import Prelude
import Data.Time.Duration (Milliseconds)
import Node.Path (FilePath)
import Node.URL (URL)
import Yoga.JSON (class WriteForeign, writeImpl)

newtype YoutubeUrl = YoutubeUrl URL

newtype State = State
  { cutVideo :: DurationRange
  , youtubeUrl :: YoutubeUrl
  , filename :: FilePath
  , reverseLoop :: Boolean
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
  , size :: Int
  , color :: Color
  , screenPosition :: Position
  }

data Font = Impact | ArialBlack
data Color = White | Black | LightGreen | LightOrange | Yellow
data Position = Top | Bottom

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

instance WriteForeign YoutubeUrl where
  writeImpl (YoutubeUrl url ) = writeImpl (show url)
instance Show YoutubeUrl where
  show (YoutubeUrl url) = show url

derive newtype instance writeDurationRange :: WriteForeign DurationRange
derive newtype instance writeSubtitle :: WriteForeign Subtitle
derive newtype instance writeState :: WriteForeign State


-- instance WriteForeign State where
--   writeImpl (State { cutVideo , youtubeUrl , filename , reverseLoop , artist , title , subtitles}) =
--     { cutVideo : writeImpl cutVideo
--   , youtubeUrl : writeImpl youtubeUrl
--   , filename : writeImpl filename
--   , reverseLoop : writeImpl reverseLoop
--   , artist : writeImpl artist
--   , title : writeImpl title
--   , subtitles : writeImpl subtitles
--   }

-- instance WriteForeign DurationRange where
--   writeImpl (DurationRange { start , end}) =
--     {
--       start: writeImpl start
--       end: writeImpl end
--     }
