module Model.State.State where

import Prelude

import Conversion.String (capitalizeFirst)
import Data.Array (group, null, sort)
import Data.Array.NonEmpty (NonEmptyArray, toArray)
import Data.Either (Either(..))
import Data.Maybe (maybe)
import Data.Newtype (class Newtype)
import Data.String (joinWith, length)
import Data.String.Common (toLower, trim)
import Data.Time.Duration (Milliseconds(..))
import Data.Traversable (traverse_)
import Data.URL (URL, fromString, toString)
import Data.Validation.Semigroup (isValid)
import Foreign (ForeignError(..), fail)
import Node.Path (FilePath)
import Validations.YoutubeValidation (youtubeUrlValidation)
import Web.File.File (File)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)

-- Type Definitions -----------------------------------------------------------

newtype WURL = WURL URL
data Source = LocalFile File | WebURL WURL

newtype State = State
  { cutVideo :: DurationRange
  , source :: Source
  , filename :: FilePath
  , reverseLoop :: Boolean
  , uploadLocalFile :: Boolean
  , artist :: String
  , title :: String
  , subtitles :: Array Subtitle
  , shiftVideoSync :: Milliseconds
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
  show ArialBlack = "Arial Black"

instance Show Color where
  show White = "#ffffff"
  show Black = "#000000"
  show LightGreen = "#ABEBC6"
  show LightOrange = "#FAD7A0"
  show Yellow = "#FFFF00"

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

instance Eq Source where
  eq (LocalFile _) (LocalFile _) = true
  eq (WebURL w1) (WebURL w2) = w1 == w2
  eq _ _ = false

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
    if s == "LocalFile" then pure (LocalFile importedLocalFilePlaceholder)
    else maybe (fail $ TypeMismatch "Source" $ "Invalid Source: " <> s) (pure <<< WebURL <<< WURL) (fromString s)

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

subtitlesToString :: Array Subtitle -> String
subtitlesToString subtitles = joinWith "\n" subtitleGroupsValues
  where
  subtitleGroups = (sort >>> group) subtitles
  subtitleToLower (Subtitle { value }) = (toLower <<< trim) value

  groupToString :: NonEmptyArray Subtitle -> String
  groupToString group = (capitalizeFirst <<< joinWith " " <<< map subtitleToLower <<< toArray) group
  subtitleGroupsValues = groupToString <$> subtitleGroups

validateState :: State -> Either (Array String) State
validateState state@(State ({ source, filename, cutVideo: durationRange, subtitles, reverseLoop })) = do
  _ <- validateRange durationRange
  _ <- validateSubtitles subtitles reverseLoop
  _ <- validateFilename filename
  _ <- validateSource source
  pure state

validateSubtitles :: Array Subtitle -> Boolean -> Either (Array String) Unit
validateSubtitles subtitles reverseLoop = do
  _ <- traverse_ (\(Subtitle { videoPosition, value }) -> validateRange videoPosition *> validateSubtitleValue value) subtitles
  if reverseLoop && (not <<< null) subtitles then Left [ "ReverseLoop and subtitles not supported" ] else Right unit

validateRange :: DurationRange -> Either (Array String) Unit
validateRange (DurationRange { start: (Milliseconds start), end: (Milliseconds end) })
  | start < end - 100.0 = Right unit
  | otherwise = Left [ "State Validation: range start >= end - 100" ]

validateSubtitleValue :: String -> Either (Array String) Unit
validateSubtitleValue v =
  if length v > 30 then Left [ "State Validation: subtitle too long. > 30 chars" ] else Right unit

validateFilename :: String -> Either (Array String) Unit
validateFilename v -- TODO: should check for the prefix
  | length v > 50 = Left [ "State Validation: filename too long. > 50 chars" ]
  | otherwise = Right unit

validateSource :: Source -> Either (Array String) Unit
validateSource (LocalFile _) = Right unit
validateSource (WebURL (WURL url)) =
  if isValid (youtubeUrlValidation "source" (toString url)) then Right unit else Left [ "State Validation: source must be a valid YouTube URL" ]
