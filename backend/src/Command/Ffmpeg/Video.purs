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

normalizeVideo :: FilePath -> Milliseconds -> Aff ExecaResult
normalizeVideo filename shiftVideoSync = do
  finally (normaliseVideoCleanup filename) (makeNormalizeVideo filename shiftVideoSync)

makeNormalizeVideo :: FilePath -> Milliseconds -> Aff ExecaResult
makeNormalizeVideo filename shiftVideoSync = do
  args <- liftEffect $ normalizeVideoArgs <$> mp4 filename <*> tempVideo filename <*> pure shiftVideoSync
  process <- runCommand args FfmpegGifError "ffmpeg"
  process.getResult

normalizeVideoArgs :: FilePath -> FilePath -> Milliseconds -> Array String
normalizeVideoArgs mp4 tempVideo (Milliseconds shiftVideoSync) =
  baseFlagsInput <> inputFlags <> codecFlags <> baseFlagsOutput <> [ show tempVideo ]
  where
  codecFlags =
    [ "-c:v"
    , "libx264"
    , "-c:a"
    , "aac"
    , "-af"
    , "\"loudnorm=I=-16:TP=-1.5:LRA=11\""
    ]
  seekStart =
    millisecondsToSecondsString (Milliseconds (abs shiftVideoSync)) (Just '.')
  inputFlags =
    if shiftVideoSync == 0.0 then [ "-i", show mp4 ]
    else
      [ "-itsoffset"
      , millisecondsToOffsetSeconds shiftVideoSync
      , "-i"
      , show mp4
      , "-i"
      , show mp4
      , "-map"
      , "1:a"
      , "-map"
      , "0:v"
      , "-ss"
      , seekStart
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
  process <- runCommand args FfmpegVideoError "ffmpeg"
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
