module Model.State.State where

import Effect (Effect)

import Prelude
import Data.Time.Duration (Milliseconds)
import Node.Path (FilePath)
import Data.URL (URL, toString)
import Yoga.JSON (class WriteForeign, writeImpl, writeJSON)

-------------------------------------------------------------------------------
--                    Copy Pasted between Frontend↔Backend                   --
-------------------------------------------------------------------------------

newtype WURL = WURL URL

newtype State = State
  { cutVideo :: DurationRange
  , youtubeUrl :: WURL
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

derive newtype instance writeDurationRange :: WriteForeign DurationRange
derive newtype instance writeSubtitle :: WriteForeign Subtitle

instance WriteForeign WURL where
  writeImpl (WURL url) = writeImpl (toString url)

derive newtype instance writeState :: WriteForeign State

-- stateToJson :: State -> Effect String
-- stateToJson (State { cutVideo, youtubeUrl, filename, reverseLoop, artist, title, subtitles }) = do
--   youtubeUrlString <- href youtubeUrl
--   pure $ writeJSON
--     { cutVideo: writeImpl cutVideo
--     , youtubeUrl: writeImpl youtubeUrlString
--     , filename: writeImpl filename
--     , reverseLoop: writeImpl reverseLoop
--     , artist: writeImpl artist
--     , title: writeImpl title
--     , subtitles: writeImpl subtitles
--     }
