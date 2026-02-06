module Command.Ffmpeg.Video where

import Command.Command (runCommand)
import Constants (mp4, tempVideo)
import Effect.Aff (Aff, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiError (MinsiError(..))
import Node.FS.Sync (rm, rename)
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)
import Prelude

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
  log $ "Execute Command, delete source video: " <> show filepathMp4
  rm filepathMp4
  log $ "Execute Command, rename:" <> show filepathTempVideo <> " into " <> filepathMp4
  rename filepathTempVideo filepathMp4
