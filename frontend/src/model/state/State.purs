module Model.State.State where

import Prelude
import Data.Time.Duration (Milliseconds(..))
import Node.Path (FilePath)
import Node.URL (URL)

data State = State
  { cutVideo :: DurationRange
  , youtubeUrl :: URL
  , filename :: FilePath
  , reverseLoop :: Boolean
  , artist :: String
  , title :: String
  , subtitles :: Array Subtitle
  }

data DurationRange = DurationRange
  { start :: Milliseconds
  , end :: Milliseconds
  }

data Subtitle = Subtitle
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

