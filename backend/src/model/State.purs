module Model.State where

import Prelude
import Data.Array (null)
import Data.Maybe (maybe)
import Data.Time.Duration (Milliseconds(..))
import Node.Path (FilePath)
import Data.Foldable (traverse_)
import Foreign.Generic.Class (class Decode)
import Data.URL (URL, fromString)
import Yoga.JSON
  ( class ReadForeign
  , readImpl
  )
import Foreign (fail, ForeignError(TypeMismatch))
import Data.Either (Either(..))

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
    maybe (fail $ TypeMismatch "URL" $ "Invalid URL: " <> s) (pure <<< WURL) (fromString s)

instance ReadForeign Source where
  readImpl f = do
    s <- readImpl f
    if s == "LocalFile" then pure LocalFile
    else maybe (fail $ TypeMismatch "Source" $ "Invalid Source: " <> s) (pure <<< WebURL <<< WURL) (fromString s)

instance Decode State where
  decode = readImpl

instance Show Position where
  show Top = "Top"
  show Bottom = "Bottom"

instance Show Color where
  show White = "#ffffff"
  show Black = "#000000"
  show LightGreen = "#ABEBC6"
  show LightOrange = "#FAD7A0"
  show Yellow = "#FFFF00"

instance Show Font where
  show Impact = "Impact"
  show ArialBlack = "Arial Black"

derive instance eqFont :: Eq Font
derive instance eqColor :: Eq Color
derive instance eqPosition :: Eq Position
derive newtype instance eqDurationRange :: Eq DurationRange
derive newtype instance eqSubtitle :: Eq Subtitle

instance Show DurationRange where
  show (DurationRange { start: Milliseconds s, end: Milliseconds e }) =
    "DurationRange { start: " <> show s <> " ms, end: " <> show e <> " ms }"

instance Show Subtitle where
  show (Subtitle { videoPosition, value, font, fontSize, color, screenPosition }) =
    "Subtitle { videoPosition: " <> show videoPosition <> ", value: " <> show value <> ", font: " <> show font <> ", fontSize: " <> show fontSize <> ", color: " <> show color <> ", screenPosition: " <> show screenPosition <> " }"

instance Ord Subtitle where
  compare (Subtitle { videoPosition: (DurationRange { start: Milliseconds str1 }) }) (Subtitle { videoPosition: (DurationRange { start: Milliseconds str2 }) }) =
    compare str1 str2

validateState :: State -> Either (Array String) State
validateState state@(State ({ cutVideo: durationRange, subtitles, reverseLoop })) = do
  _ <- validateRange durationRange
  _ <- validateSubtitles subtitles reverseLoop
  pure state

validateSubtitles :: Array Subtitle -> Boolean -> Either (Array String) Unit
validateSubtitles subtitles reverseLoop = do
  _ <- traverse_ (\(Subtitle { videoPosition }) -> validateRange videoPosition) subtitles
  if reverseLoop && (not <<< null) subtitles then Left [ "ReverseLoop and subtitles not supported" ]
  else Right unit

validateRange :: DurationRange -> Either (Array String) Unit
validateRange (DurationRange { start: (Milliseconds start), end: (Milliseconds end) })
  | start < end - 100.0 = Right unit
  | otherwise = Left [ "State Validation: range start >= end - 100" ]
