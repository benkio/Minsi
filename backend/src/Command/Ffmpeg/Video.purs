module Command.Ffmpeg.Video where

import Prelude

import Command.Command (runCommand)
import Command.Ffmpeg.Base (baseFlagsInput, baseFlagsOutput)
import Constants (mp4, tempVideo)
import Conversion.Time (millisecondsToSecondsString)
import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (class Newtype, unwrap)
import Data.Number (abs)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (Aff, apathize, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..), throwMinsiError)
import Node.FS.Aff (rm)
import Node.FS.Sync as FSSync
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

newtype FfmpegInput = FfmpegInput
  { input :: FilePath
  , filename :: String
  , maybeStart :: Maybe Milliseconds
  , maybeEnd :: Maybe Milliseconds
  }

derive instance newtypeFfmpegInput :: Newtype FfmpegInput _

ffmpegVideoTimeout :: Maybe Milliseconds
ffmpegVideoTimeout = Nothing

normalizeVideo :: FilePath -> Milliseconds -> Boolean -> Aff ExecaResult
normalizeVideo filename shiftVideoSync reverseLoop = do
  finally (normaliseVideoCleanup filename) (makeNormalizeVideo filename shiftVideoSync reverseLoop)

makeNormalizeVideo :: FilePath -> Milliseconds -> Boolean -> Aff ExecaResult
makeNormalizeVideo filename shiftVideoSync reverseLoop = do
  args <- liftEffect $ normalizeVideoArgs <$> mp4 filename <*> tempVideo filename <*> pure shiftVideoSync <*> pure reverseLoop
  process <- runCommand ffmpegVideoTimeout args FfmpegGifError "ffmpeg"
  process.getResult

normalizeVideoArgs :: FilePath -> FilePath -> Milliseconds -> Boolean -> Array String
normalizeVideoArgs mp4 tempVideo (Milliseconds shiftVideoSync) reverseLoop =
  if reverseLoop then baseFlagsInput <> inputFlags <> reverseLoopFilterFlags <> codecFlags <> baseFlagsOutput <> [ tempVideo ]
  else baseFlagsInput <> inputFlags <> passthroughAudioFlags <> codecFlags <> baseFlagsOutput <> [ tempVideo ]
  where
  loudNormArg = "loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true"
  codecFlags =
    [ "-c:v"
    , "libx264"
    , "-c:a"
    , "aac"
    ]
  seekStart =
    millisecondsToSecondsString (Milliseconds (abs shiftVideoSync)) (Just '.')
  audioStreamRef = if shiftVideoSync == 0.0 then "[0:a]" else "[1:a]"
  videoStreamRef = "[0:v]"
  inputFlags =
    if shiftVideoSync == 0.0 then [ "-i", mp4 ]
    else
      [ "-itsoffset"
      , millisecondsToOffsetSeconds shiftVideoSync
      , "-i"
      , mp4
      , "-i"
      , mp4
      , "-ss"
      , seekStart
      ]
  passthroughAudioFlags =
    if shiftVideoSync == 0.0 then [ "-af", loudNormArg ]
    else [ "-map", "0:v", "-map", "1:a", "-af", loudNormArg ]
  reverseLoopFilterFlags =
    [ "-filter_complex"
    , videoStreamRef
        <> "split[vfwd][vtmp];"
        <> "[vtmp]reverse[vrev];"
        <> "[vfwd][vrev]concat=n=2:v=1:a=0[v];"
        <> audioStreamRef
        <> "asplit[afwd][atmp];"
        <> "[atmp]areverse[arev];"
        <> "[afwd][arev]concat=n=2:v=0:a=1[aloop];"
        <> "[aloop]"
        <> loudNormArg
        <> "[a]"
    , "-map"
    , "[v]"
    , "-map"
    , "[a]"
    ]

millisecondsToOffsetSeconds :: Number -> String
millisecondsToOffsetSeconds ms = show (ms / 1000.0)

normaliseVideoCleanup :: String -> Aff Unit
normaliseVideoCleanup filename = liftEffect do
  filepathMp4 <- mp4 filename
  filepathTempVideo <- tempVideo filename
  log $ "[Command/Video] Execute Command, delete source video: " <> show filepathMp4
  FSSync.rm filepathMp4
  log $ "[Command/Video] Execute Command, rename:" <> show filepathTempVideo <> " into " <> filepathMp4
  FSSync.rename filepathTempVideo filepathMp4

-- Uploaded/Local ---------------------------------------------------------------

cutVideo :: FfmpegInput -> Aff ExecaResult
cutVideo ffmpegInput = do
  _ <- liftEffect $ validateAndResolveLocalFile ffmpegInput
  finally (rm (unwrap ffmpegInput).input) (cutAndConvertUploadedVideo ffmpegInput)

validateAndResolveLocalFile :: FfmpegInput -> Effect FilePath
validateAndResolveLocalFile (FfmpegInput { input, filename }) = do
  fp <- mp4 filename
  fileExists <- FSSync.exists input
  when (not fileExists) do
    throwMinsiError (FfmpegVideoError ("🚫 Error: Expected " <> show input <> " but not was found. Retry the `compute` and the upload"))
  log ("[Ytdlp] Cut " <> show input <> " To " <> show fp)
  pure fp

cutAndConvertUploadedVideo :: FfmpegInput -> Aff ExecaResult
cutAndConvertUploadedVideo ffmpegInput@(FfmpegInput { input, filename }) = do
  filepathMp4 <- liftEffect $ mp4 filename
  apathize $ rm filepathMp4
  liftEffect $ log $ "[Command/Video] Execute Command, Cut & Convert:" <> show input <> " into " <> filepathMp4
  let args = cutAndConvertUpladedVideoArgs filepathMp4 ffmpegInput
  process <- runCommand ffmpegVideoTimeout args FfmpegVideoError "ffmpeg"
  process.getResult

cutAndConvertUpladedVideoArgs :: FilePath -> FfmpegInput -> Array String
cutAndConvertUpladedVideoArgs output (FfmpegInput { input, maybeStart, maybeEnd }) =
  baseFlagsInput <> [ "-i", input, "-c:v", "libx264", "-c:a", "aac" ]
    <> maybe [] (\s -> [ "-ss", s ]) maybeStartStr
    <> maybe [] (\s -> [ "-t", s ]) maybeDurationStr
    <> baseFlagsOutput
    <> [ output ]
  where
  maybeStartStr = map (\s -> millisecondsToSecondsString s (Just '.')) maybeStart
  maybeDurationStr = map (\e -> millisecondsToSecondsString e (Just '.')) maybeDuration
  maybeDuration = do
    (Milliseconds start) <- maybeStart
    (Milliseconds end) <- maybeEnd
    pure $ Milliseconds (end - start)
