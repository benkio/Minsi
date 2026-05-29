module Model.State.State where

import Prelude

import Conversion.String (capitalizeFirst)
import Data.Array (group, sort)
import Data.Array.NonEmpty (NonEmptyArray, toArray)
import Data.Maybe (maybe)
import Data.String (joinWith)
import Data.String.Common (toLower, trim)
import Data.Newtype (class Newtype)
import Data.Time.Duration (Milliseconds(..))
import Data.URL (URL, fromString, toString)
import Foreign (ForeignError(..), fail)
import Foreign.Index (readProp)
import Node.Path (FilePath)
import Web.File.File (File)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)

-------------------------------------------------------------------------------
--                    Copy Pasted between Frontend↔Backend                   --
-------------------------------------------------------------------------------

-- Type Definitions -----------------------------------------------------------

newtype WURL = WURL URL
data Source = LocalFile File | WebURL WURL

instance Eq Source where
  eq (LocalFile _) (LocalFile _) = true
  eq (WebURL a) (WebURL b) = eq a b
  eq _ _ = false

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

-- EQ Instances -----------------------------------------

derive instance Eq WURL
derive instance Eq Font
derive instance Eq Color
derive instance Eq Position
derive newtype instance eqDurationRange :: Eq DurationRange
instance Eq Subtitle where
  eq (Subtitle { font: f1, screenPosition: sp1, color: c1 }) (Subtitle { font: f2, screenPosition: sp2, color: c2 }) =
    f1 == f2 && sp1 == sp2 && c1 == c2

-- Show Instances -----------------------

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

instance Show Subtitle where
  show
    ( Subtitle
        { videoPosition
        , value
        , font
        , fontSize
        , color
        , screenPosition
        }
    ) =
    "Subtitle: " <> show videoPosition
      <> ", value: "
      <> show value
      <> ", font: "
      <> show font
      <> ", fontSize: "
      <> show fontSize
      <> ", color: "
      <> show color
      <> ", screenPosition: "
      <> show screenPosition

instance Show Source where
  show (LocalFile _) = "LocalFile"
  show (WebURL w) = "WebURL " <> show w

instance Show WURL where
  show (WURL url) = toString url

instance Show DurationRange where
  show (DurationRange { start: Milliseconds s, end: Milliseconds e }) =
    "DurationRange: " <> show s <> " → " <> show e

-- WriteForeign Instances -----------------------------------------------------

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
  writeImpl (LocalFile _) = writeImpl "LocalFile"
  writeImpl (WebURL w) = writeImpl w

derive newtype instance writeState :: WriteForeign State

foreign import importedLocalFilePlaceholder :: File

instance ReadForeign DurationRange where
  readImpl obj = do
    startN <- readProp "start" obj >>= readImpl
    endN <- readProp "end" obj >>= readImpl
    pure $ DurationRange { start: Milliseconds startN, end: Milliseconds endN }

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

derive newtype instance readSubtitle :: ReadForeign Subtitle

instance ReadForeign WURL where
  readImpl f = do
    s <- readImpl f
    maybe (fail $ TypeMismatch "URL" $ "Invalid URL: " <> s) (pure <<< WURL) (fromString s)

instance ReadForeign Source where
  readImpl f = do
    s <- readImpl f
    if s == "LocalFile" then pure $ LocalFile importedLocalFilePlaceholder
    else maybe (fail $ TypeMismatch "Source" $ "Invalid Source: " <> s) (pure <<< WebURL <<< WURL) (fromString s)

derive newtype instance readState :: ReadForeign State

-- Other Typeclass Instances --------------------------

derive instance Newtype State _

instance Ord Subtitle where
  compare (Subtitle { videoPosition: (DurationRange { start: Milliseconds str1 }) }) (Subtitle { videoPosition: (DurationRange { start: Milliseconds str2 }) }) =
    compare str1 str2

-- Pure Functions ---------------------------------------------------------

isLocalFile :: Source -> Boolean
isLocalFile (LocalFile _) = true
isLocalFile (WebURL _) = false

shiftDurationRange :: Milliseconds -> DurationRange -> DurationRange
shiftDurationRange (Milliseconds millis) (DurationRange { start: (Milliseconds s), end: (Milliseconds e) }) =
  DurationRange { start: (Milliseconds (s + millis)), end: (Milliseconds (e + millis)) }

shiftSubtitle :: Milliseconds -> Subtitle -> Subtitle
shiftSubtitle millis (Subtitle { videoPosition, value, font, fontSize, color, screenPosition }) =
  Subtitle { videoPosition: shiftDurationRange millis videoPosition, value, font, fontSize, color, screenPosition }

subtitlesToString :: Array Subtitle -> String
subtitlesToString subtitles = joinWith "\n" subtitleGroupsValues
  where
  subtitleGroups = (sort >>> group) subtitles
  subtitleToLower (Subtitle { value }) = (toLower <<< trim) value

  groupToString :: NonEmptyArray Subtitle -> String
  groupToString group = (capitalizeFirst <<< joinWith " " <<< map subtitleToLower <<< toArray) group
  subtitleGroupsValues = groupToString <$> subtitleGroups
