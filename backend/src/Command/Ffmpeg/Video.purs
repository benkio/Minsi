module Command.Ffmpeg.Video where

import Prelude

import Command.Command (runCommand)
import Constants (mp4, tempVideo)
import Conversion.Time (millisecondsToSecondsString)
import Data.Maybe (Maybe(..), maybe)
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (Aff, apathize, finally)
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
  args <- liftEffect $ normalizeVideoArgs <$> mp4 filename <*> tempVideo filename
  process <- runCommand args FfmpegGifError "ffmpeg"
  process.getResult

normalizeVideoArgs :: FilePath -> FilePath -> Array String
normalizeVideoArgs mp4 tempVideo =
  [ "-hide_banner", "-loglevel", "warning", "-i", show mp4, "-c:v", "libx264", "-c:a", "aac", show tempVideo ]

normaliseVideoCleanup :: String -> Aff Unit
normaliseVideoCleanup filename = liftEffect do
  filepathMp4 <- mp4 filename
  filepathTempVideo <- tempVideo filename
  log $ "[Command/Video] Execute Command, delete source video: " <> show filepathMp4
  rm filepathMp4
  log $ "[Command/Video] Execute Command, rename:" <> show filepathTempVideo <> " into " <> filepathMp4
  rename filepathTempVideo filepathMp4

-- Uploaded ---------------------------------------------------------------

cutAndConvertUploadedVideo :: FilePath -> String -> Maybe Milliseconds -> Maybe Milliseconds -> Aff ExecaResult
cutAndConvertUploadedVideo uploadedFilepath filename maybeStart maybeEnd = do
  filepathMp4 <- liftEffect $ mp4 filename
  apathize $ liftEffect $ rm filepathMp4
  liftEffect $ log $ "[Command/Video] Execute Command, Cut & Convert:" <> show uploadedFilepath <> " into " <> filepathMp4
  let args = cutAndConvertUpladedVideoArgs uploadedFilepath filepathMp4 startStr durationStr
  process <- runCommand args FfmpegVideoError "ffmpeg"
  process.getResult
  where
  startStr = millisecondsToSecondsString <$> maybeStart <*> pure (Just '.')
  durationStr = millisecondsToSecondsString <$> maybeDuration <*> pure (Just '.')
  maybeDuration = do
    (Milliseconds start) <- maybeStart
    (Milliseconds end) <- maybeEnd
    pure $ Milliseconds (end - start)

cutAndConvertUpladedVideoArgs :: FilePath -> FilePath -> Maybe String -> Maybe String -> Array String
cutAndConvertUpladedVideoArgs uploaded mp4 maybeStartStr maybeEndStr =
  [ "-hide_banner", "-loglevel", "warning", "-i", uploaded, "-c:v", "libx264", "-c:a", "aac" ]
  <> maybe [] (\s -> [ "-ss", s ]) maybeStartStr
  <> maybe [] (\s -> [ "-t", s ]) maybeEndStr
  <> [ mp4 ]
