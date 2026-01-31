module Command.Ffmpeg.Gif where

import Data.Foldable (intercalate, fold)
import Constants (srt, txt)
import Conversion.Time (millisecondsToSecondsString)
import Node.Path (FilePath)
import Model.State (DurationRange(..), Subtitle(..), Position(..))
import Effect (Effect)
import Prelude
import Data.Array (mapWithIndex)
import Data.Maybe (Maybe(..))
import Node.Buffer (fromString)
import Node.FS.Sync (writeFile, rm)
import Node.Encoding (Encoding(..))

--TODO: implement
-- makeGif :: Effect ExecaResult
-- makeGif = pure unit

--TODO: implement
makePlainGif :: Effect Unit
makePlainGif = pure unit

writeSrtFile :: FilePath -> String -> Effect Unit
writeSrtFile filename srtContent = do 
  f <- srt filename
  bufferContent <- fromString srtContent UTF8
  writeFile f bufferContent

deleteSrtFile :: FilePath -> Effect Unit
deleteSrtFile fp = srt fp >>= rm

writeMergeTxt :: FilePath -> Array FilePath -> Effect Unit
writeMergeTxt filename files = do
  f <- txt filename
  bufferContent <- fromString content UTF8
  writeFile f bufferContent
  where
    content = intercalate "\n" $ files <#> (\f -> "file '"<>f<>"'")

deleteTxtFile :: FilePath -> Effect Unit
deleteTxtFile fp = txt fp >>= rm

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
