module Command.Ffmpeg.Gif where

import Conversion.Time (millisecondsToSecondsString)

import Model.State (DurationRange(..), Subtitle(..), validateRange, validateSubtitles, Font(..), Color(..), Position(..))
import Effect (Effect)
import Node.Library.Execa (ExecaResult)
import Prelude
import Data.Array (mapWithIndex)
import Data.Foldable (fold)
import Data.Maybe (Maybe(..))

--TODO: implement
-- makeGif :: Effect ExecaResult
-- makeGif = pure unit

--TODO: implement
makePlainGif :: Effect Unit
makePlainGif = pure unit

--TODO: implement
makeSrtFile :: Effect Unit
makeSrtFile = pure unit

--TODO: implement
burnSrtIntoGif :: Effect Unit
burnSrtIntoGif = pure unit

--TODO: implement
makeReverseGif :: Effect Unit
makeReverseGif = pure unit

--TODO: implement
mergeVideos :: Effect Unit
mergeVideos = pure unit

makeSrtsString :: Array Subtitle -> String
makeSrtsString = fold <<< mapWithIndex (\i s -> makeSrtString (i + 1) s)

makeSrtString :: Int -> Subtitle -> String
makeSrtString index (Subtitle { videoPosition : (DurationRange {start:start, end:end}) , value : value, font : font, fontSize : fontSize, color : color, screenPosition :screenPosition }) =
  show index <> "\n"
    <> startStr <> " --> " <> endStr <> "\n"
    <> positionStr <> fontStr <> "\n"
    <> "\n"
  where
    startStr = millisecondsToSecondsString start Nothing
    endStr = millisecondsToSecondsString end Nothing
    positionStr = if screenPosition == Top then "{\\an8}" else ""
    fontStr = "<font face=\"" <> show font <> "\" size=\"" <> show fontSize <> "px\" color=\"" <> show color <> "\">" <> value <> "</font>"
