module Command.Ffmpeg.Gif where

import Prelude

import Command.Command (runCommand)
import Command.Ffmpeg.Base (baseFlagsInput, baseFlagsOutput)
import Constants (mp4, gif, srt)
import Conversion.Time (millisecondsToSecondsString)
import Data.Array (mapWithIndex, null, singleton)
import Data.Foldable (fold)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (Aff, apathize, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..))
import Model.State.State (DurationRange(..), Subtitle(..), Position(..), State(..))
import Node.Buffer (fromString)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (rm, writeFile)
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

makeGifTimeout :: Maybe Milliseconds
makeGifTimeout = Just (Milliseconds 60000.0)

makeGif :: State -> Aff (Array ExecaResult)
makeGif (State { filename, subtitles })
  | (not <<< null) subtitles = finally (subtitleGifCleanup filename) (singleton <$> makeSubtitleGif filename subtitles)
  | otherwise = singleton <$> makePlainGif filename

makePlainGif :: FilePath -> Aff ExecaResult
makePlainGif filename = do
  { filepathMp4, filepathGif } <- liftEffect $ resolvePlainGifPaths filename
  apathize (liftEffect $ log ("[Gif] Delete " <> show filepathGif) *> rm filepathGif)
  let args = addFfmpegPlainGifArgs filepathMp4 filepathGif
  process <- runCommand makeGifTimeout args FfmpegGifError "ffmpeg"
  process.getResult
  where
  resolvePlainGifPaths fn = do
    p <- mp4 fn
    g <- gif fn
    pure { filepathMp4: p, filepathGif: g }

addFfmpegPlainGifArgs :: FilePath -> FilePath -> Array String
addFfmpegPlainGifArgs mp4 gif =
  baseFlagsInput <> [ "-i", mp4, "-an" ] <> baseFlagsOutput <> [ gif ]

makeSubtitleGif :: FilePath -> Array Subtitle -> Aff ExecaResult
makeSubtitleGif filename subtitles = do
  { filepathMp4, filepathGif, filepathSrt } <- liftEffect $ resolveSubtitleGifPaths filename
  apathize (liftEffect $ log ("[Gif] Delete " <> show filepathGif) *> rm filepathGif)
  liftEffect $ writeSrtFile filename (makeSrtsString subtitles)
  let args = addFfmpegSubtitleGifArgs filepathMp4 filepathGif filepathSrt
  process <- runCommand makeGifTimeout args FfmpegGifError "ffmpeg"
  process.getResult
  where
  resolveSubtitleGifPaths fn = do
    p <- mp4 fn
    g <- gif fn
    s <- srt fn
    pure { filepathMp4: p, filepathGif: g, filepathSrt: s }

addFfmpegSubtitleGifArgs :: FilePath -> FilePath -> FilePath -> Array String
addFfmpegSubtitleGifArgs mp4 gif srt =
  baseFlagsInput <> [ "-i", mp4, "-an", "-vf", subtitleArg ] <> baseFlagsOutput <> [ gif ]
  where
  subtitleArg = "subtitles=" <> srt

-- Can't really support multiple font dirs 🤔
-- "subtitles="<>srt<>":fontsdir='"<>${fontDirectory}<> "'",

subtitleGifCleanup :: String -> Aff Unit
subtitleGifCleanup filename = liftEffect $
  log ("[Gif] Execute Command: deleteSrt " <> show filename) *> srt filename >>= rm

-- Extra Files -------------------------------------------------

writeSrtFile :: FilePath -> String -> Effect Unit
writeSrtFile filename srtContent = do
  f <- srt filename
  bufferContent <- fromString srtContent UTF8
  log $ "[Gif] Execute Command: writeFile " <> show f <> " with content " <> srtContent
  writeFile f bufferContent

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
