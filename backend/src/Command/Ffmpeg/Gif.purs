module Command.Ffmpeg.Gif where

import Effect.Console (log)
import MinsiError (MinsiError(..), throwMinsiError)
import Command.Command (runCommand)
import Constants (mp4, gif, srt, txt, reversed, reversedFull)
import Conversion.Time (millisecondsToSecondsString)
import Data.Array (mapWithIndex, null, singleton)
import Data.Foldable (intercalate, fold, traverse_)
import Data.Maybe (Maybe(..))
import Data.String.Common (toUpper, trim)
import Effect (Effect)
import Effect.Aff (Aff, finally)
import Effect.Class (liftEffect)
import Model.State (DurationRange(..), Subtitle(..), Position(..), State(..))
import Node.Buffer (fromString)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (writeFile, rm, rename)
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)
import Prelude

makeGif :: State -> Aff (Array ExecaResult)
makeGif (State { filename, subtitles, reverseLoop })
  | reverseLoop && null subtitles = finally (reverseGifCleanup filename) (makeReverseGif filename)
  | not reverseLoop && (not <<< null) subtitles = finally (subtitleGifCleanup filename) (singleton <$> makeSubtitleGif filename subtitles)
  | not reverseLoop && null subtitles = singleton <$> makePlainGif filename
  | otherwise = liftEffect $ throwMinsiError (FfmpegGifError "Unsupported gif operation")

makePlainGif :: FilePath -> Aff ExecaResult
makePlainGif filename = do
  filepathMp4 <- liftEffect $ mp4 filename
  filepathGif <- liftEffect $ gif filename
  let args = addFfmpegPlainGifArgs filepathMp4 filepathGif
  process <- runCommand args FfmpegGifError "ffmpeg"
  process.getResult

addFfmpegPlainGifArgs :: FilePath -> FilePath -> Array String
addFfmpegPlainGifArgs mp4 gif =
  [ "-hide_banner", "-loglevel", "warning", "-i", show mp4, "-an", show gif ]

makeSubtitleGif :: FilePath -> Array Subtitle -> Aff ExecaResult
makeSubtitleGif filename subtitles = do
  filepathMp4 <- liftEffect $ mp4 filename
  filepathGif <- liftEffect $ gif filename
  filepathSrt <- liftEffect $ srt filename

  let subtitleContent = makeSrtsString subtitles
  liftEffect $ writeSrtFile filename subtitleContent

  let args = addFfmpegSubtitleGifArgs filepathMp4 filepathGif filepathSrt
  process <- runCommand args FfmpegGifError "ffmpeg"
  process.getResult

addFfmpegSubtitleGifArgs :: FilePath -> FilePath -> FilePath -> Array String
addFfmpegSubtitleGifArgs mp4 gif srt =
  [ "-hide_banner", "-loglevel", "warning", "-i", show mp4, "-an", "-vf", show subtitleArg, show gif ]
  where
  subtitleArg = "subtitles=" <> srt

-- Can't really support multiple font dirs 🤔
-- "subtitles="<>srt<>":fontsdir='"<>${fontDirectory}<> "'",

makeReverseGif :: FilePath -> Aff (Array ExecaResult)
makeReverseGif filename = do
  filepathGif <- liftEffect $ gif filename
  filepathReversed <- liftEffect $ reversed filename

  plainGif <- makePlainGif filename
  reversedGif <- makeReverseSingleGif filename
  merge <- mergeVideos filename filepathGif filepathReversed

  pure [ plainGif, reversedGif, merge ]

makeReverseSingleGif :: FilePath -> Aff ExecaResult
makeReverseSingleGif filename = do
  filepathReversed <- liftEffect $ reversed filename
  filepathGif <- liftEffect $ gif filename
  let args = addFfmpegReverseGifArgs filepathGif filepathReversed
  process <- runCommand args FfmpegGifError "ffmpeg"
  process.getResult

addFfmpegReverseGifArgs :: FilePath -> FilePath -> Array String
addFfmpegReverseGifArgs filepathGif filepathReversed =
  [ "-hide_banner", "-loglevel", "warning", "-i", show filepathGif, "-vf", "reverse", show filepathReversed ]

mergeVideos :: FilePath -> FilePath -> FilePath -> Aff ExecaResult
mergeVideos filename filepathGif filepathReversed = do
  filepathTxt <- liftEffect $ txt filename
  filepathReversedFull <- liftEffect $ reversedFull filename
  liftEffect $ writeMergeTxt filename [ filepathGif, filepathReversed ]
  let args = addFfmpegMergeVideosArgs filepathTxt filepathReversedFull
  process <- runCommand args FfmpegGifError "ffmpeg"
  process.getResult

addFfmpegMergeVideosArgs :: FilePath -> FilePath -> Array String
addFfmpegMergeVideosArgs filepathTxt filepathReversedFull =
  [ "-hide_banner", "-loglevel", "warning", "-f", "concat", "-safe", "0", "-i", show filepathTxt, "-c", "copy", show filepathReversedFull ]

reverseGifCleanup :: String -> Aff Unit
reverseGifCleanup filename = liftEffect $ do
  filepathGif <- liftEffect $ gif filename
  filepathTxt <- liftEffect $ txt filename
  filepathReversed <- liftEffect $ reversed filename
  filepathReversedFull <- liftEffect $ reversedFull filename
  let filesToDelete = [ filepathGif, filepathReversed, filepathTxt ]
  log $ "Execute Command, delete multiple files:" <> show filesToDelete
  traverse_ rm filesToDelete
  log $ "Execute Command, rename:" <> show filepathReversedFull <> " into " <> filepathGif
  rename filepathReversedFull filepathGif

subtitleGifCleanup :: String -> Aff Unit
subtitleGifCleanup filename = liftEffect $
  log "Execute Command, delete srt" *> deleteSrtFile filename

-- Extra Files -------------------------------------------------

writeSrtFile :: FilePath -> String -> Effect Unit
writeSrtFile filename srtContent = do
  f <- srt filename
  bufferContent <- fromString srtContent UTF8
  log $ "Execute Command: writeFile " <> show f <> " with content " <> srtContent
  writeFile f bufferContent

deleteSrtFile :: FilePath -> Effect Unit
deleteSrtFile fp = log ("Execute Command: deleteSrt " <> show fp) *> srt fp >>= rm

writeMergeTxt :: FilePath -> Array FilePath -> Effect Unit
writeMergeTxt filename files = do
  f <- txt filename
  bufferContent <- fromString txtContent UTF8
  log $ "Execute Command: writeFile " <> show f <> " with content " <> txtContent
  writeFile f bufferContent
  where
  txtContent = intercalate "\n" $ files <#> (\f -> "file '" <> f <> "'")

-- SRT String Creation -------------------------------------

makeSrtsString :: Array Subtitle -> String
makeSrtsString = fold <<< mapWithIndex (\i s -> makeSrtString (i + 1) s)

makeSrtString :: Int -> Subtitle -> String
makeSrtString index (Subtitle { videoPosition: (DurationRange { start: start, end: end }), value: value, font: font, fontSize: fontSize, color: color, screenPosition: screenPosition }) =
  show index <> "\n"
    <> startStr
    <> " --> "
    <> endStr
    <> "\n"
    <> positionStr
    <> fontStr
    <> "\n"
    <> "\n"
  where
  startStr = millisecondsToSecondsString start Nothing
  endStr = millisecondsToSecondsString end Nothing
  positionStr = if screenPosition == Top then "{\\an8}" else ""
  fontStr = "<font face=\"" <> show font <> "\" size=\"" <> show fontSize <> "px\" color=\"" <> show color <> "\">" <> value <> "</font>"
