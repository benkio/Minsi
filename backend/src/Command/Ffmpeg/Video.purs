module Command.Ffmpeg.Video where

import Prelude

import Command.Command (runCommand)
import Constants (mp4, tempVideo)
import Conversion.Time (millisecondsToSecondsString)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds)
import Effect.Aff (Aff, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..))
import Node.FS.Sync (rm, rename)
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

normalizeVideo :: FilePath -> Aff ExecaResult
normalizeVideo filename = do
  finally (normaliseVideoCleanup filename) (makeNormalizeVideo filename)

makeNormalizeVideo :: FilePath -> Aff ExecaResult
makeNormalizeVideo filename = do
  filepathMp4 <- liftEffect $ mp4 filename
  filepathTempVideo <- liftEffect $ tempVideo filename
  let args = normalizeVideoArgs filepathMp4 filepathTempVideo
  process <- runCommand args FfmpegGifError "ffmpeg"
  process.getResult

normalizeVideoArgs :: FilePath -> FilePath -> Array String
normalizeVideoArgs mp4 tempVideo =
  [ "-hide_banner", "-loglevel", "warning", "-i", show mp4, "-c:v", "libx264", "-c:a", "aac", show tempVideo ]

normaliseVideoCleanup :: String -> Aff Unit
normaliseVideoCleanup filename = liftEffect $ do
  filepathMp4 <- liftEffect $ mp4 filename
  filepathTempVideo <- liftEffect $ tempVideo filename
  log $ "[Command/Video] Execute Command, delete source video: " <> show filepathMp4
  rm filepathMp4
  log $ "[Command/Video] Execute Command, rename:" <> show filepathTempVideo <> " into " <> filepathMp4
  rename filepathTempVideo filepathMp4

-- Uploaded ---------------------------------------------------------------

cutAndConvertUploadedVideo :: FilePath -> String -> Milliseconds -> Milliseconds -> Aff ExecaResult
cutAndConvertUploadedVideo uploadedFilepath filename start end = do
  filepathMp4 <- liftEffect $ mp4 filename
  liftEffect $ log $ "[Command/Video] Execute Command, delete source video: " <> show filepathMp4
  liftEffect $ rm filepathMp4
  liftEffect $ log $ "[Command/Video] Execute Command, Cut & Convert:" <> show uploadedFilepath <> " into " <> filepathMp4
  let args = cutAndConvertUpladedVideoArgs uploadedFilepath filepathMp4 startStr endStr
  process <- finally (liftEffect $ rm uploadedFilepath) (runCommand args FfmpegVideoError "ffmpeg")
  process.getResult
  where
  startStr = millisecondsToSecondsString start (Just '.')
  endStr = millisecondsToSecondsString end (Just '.')

cutAndConvertUpladedVideoArgs :: FilePath -> FilePath -> String -> String -> Array String
cutAndConvertUpladedVideoArgs uploaded mp4 start end =
  [ "-hide_banner", "-loglevel", "warning", "-i", show uploaded, "-c:v", "libx264", "-c:a", "aac", "-ss", start, "-t", end, show mp4 ]
