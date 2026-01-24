module Model.State where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds)
import Node.Path (FilePath)
import Foreign.Generic.Class (class Decode)
import Data.URL (URL, fromString)
import Yoga.JSON
  ( class ReadForeign
  , readImpl
  )
import Foreign (fail, ForeignError(TypeMismatch))

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

data Font
  = Impact
  | ArialBlack

data Color
  = White
  | Black
  | LightGreen
  | LightOrange
  | Yellow

data Position
  = Top
  | Bottom

instance ReadForeign Position where
  readImpl f = do
    s <- readImpl f
    case s of
      "Top" -> pure Top
      "Bottom" -> pure Bottom
      _ -> fail $ TypeMismatch "Position" $ "Invalid Position: " <> s

instance ReadForeign Color where
  readImpl f = do
    s <- readImpl f
    case s of
      "#ffffff" -> pure White
      "#000000" -> pure Black
      "#ABEBC6" -> pure LightGreen
      "#FAD7A0" -> pure LightOrange
      "#FFFF00" -> pure Yellow
      _ -> fail $ TypeMismatch "Color" $ "Invalid Color: " <> s

instance ReadForeign Font where
  readImpl f = do
    s <- readImpl f
    case s of
      "Impact" -> pure Impact
      "Arial Black" -> pure ArialBlack
      _ -> fail $ TypeMismatch "Font" $ "Invalid Font: " <> s

derive newtype instance ReadForeign DurationRange
derive newtype instance ReadForeign Subtitle
derive newtype instance ReadForeign State

instance ReadForeign WURL where
  readImpl f = do
    s <- readImpl f
    case fromString s of
      Nothing -> fail $ TypeMismatch "URL" $ "Invalid URL: " <> s
      Just url -> pure (WURL url)

instance Decode State where
  decode = readImpl
