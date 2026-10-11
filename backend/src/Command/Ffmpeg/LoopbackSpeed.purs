module Command.Ffmpeg.LoopbackSpeed where

import Prelude

import Command.Command (runCommand)
import Command.Ffmpeg.Base (baseFlagsInput, baseFlagsOutput)
import Constants (mp4, tempVideo)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds)
import Effect.Aff (Aff, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..))
import Node.FS.Sync as FSSync
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

loopbackSpeedTimeout :: Maybe Milliseconds
loopbackSpeedTimeout = Nothing

applyLoopbackSpeed :: FilePath -> Number -> Aff ExecaResult
applyLoopbackSpeed filename loopbackSpeed = do
  finally (loopbackSpeedCleanup filename) (makeLoopbackSpeed filename loopbackSpeed)

makeLoopbackSpeed :: FilePath -> Number -> Aff ExecaResult
makeLoopbackSpeed filename loopbackSpeed = do
  args <- liftEffect $ loopbackSpeedArgs <$> mp4 filename <*> tempVideo filename <*> pure loopbackSpeed
  process <- runCommand loopbackSpeedTimeout args FfmpegVideoError "ffmpeg"
  process.getResult

loopbackSpeedArgs :: FilePath -> FilePath -> Number -> Array String
loopbackSpeedArgs input output rawSpeed =
  baseFlagsInput <> [ "-i", input, "-filter_complex", filterArg, "-map", "[v]", "-map", "[a]" ] <> codecFlags <> baseFlagsOutput <> [ output ]
  where
  speed = clampSpeed rawSpeed
  filterArg =
    "[0:v]setpts=PTS/" <> show speed <> "[v];"
      <> "[0:a]"
      <> buildAtempoArg speed
      <> ",loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true[a]"
  codecFlags =
    [ "-c:v"
    , "libx264"
    , "-c:a"
    , "aac"
    ]

clampSpeed :: Number -> Number
clampSpeed speed
  | speed < 0.25 = 0.25
  | speed > 4.0 = 4.0
  | otherwise = speed

buildAtempoArg :: Number -> String
buildAtempoArg speed
  | speed <= 0.5 = "atempo=0.5,atempo=" <> show (speed / 0.5)
  | speed <= 2.0 = "atempo=" <> show speed
  | otherwise = "atempo=2.0,atempo=" <> show (speed / 2.0)

loopbackSpeedCleanup :: String -> Aff Unit
loopbackSpeedCleanup filename = liftEffect do
  filepathMp4 <- mp4 filename
  filepathTempVideo <- tempVideo filename
  log $ "[LoopbackSpeed] delete source video: " <> show filepathMp4
  FSSync.rm filepathMp4
  log $ "[LoopbackSpeed] rename " <> show filepathTempVideo <> " into " <> show filepathMp4
  FSSync.rename filepathTempVideo filepathMp4
