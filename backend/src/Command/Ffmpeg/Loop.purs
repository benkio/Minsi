module Command.Ffmpeg.Loop where

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

loopTimeout :: Maybe Milliseconds
loopTimeout = Nothing

applyReverseLoop :: FilePath -> Aff ExecaResult
applyReverseLoop filename = do
  finally (loopCleanup filename) (makeLoop filename)

makeLoop :: FilePath -> Aff ExecaResult
makeLoop filename = do
  args <- liftEffect $ reverseLoopArgs <$> mp4 filename <*> tempVideo filename
  process <- runCommand loopTimeout args FfmpegVideoError "ffmpeg"
  process.getResult

reverseLoopArgs :: FilePath -> FilePath -> Array String
reverseLoopArgs input output =
  baseFlagsInput
    <> [ "-i"
      , input
      , "-filter_complex"
      , "[0:v]split[vfwd][vtmp];[vtmp]reverse[vrev];[vfwd][vrev]concat=n=2:v=1:a=0[v];[0:a]asplit[afwd][atmp];[atmp]areverse[arev];[afwd][arev]concat=n=2:v=0:a=1[a]"
      , "-map"
      , "[v]"
      , "-map"
      , "[a]"
      ]
    <> codecFlags
    <> baseFlagsOutput
    <> [ output ]
  where
  codecFlags =
    [ "-c:v"
    , "libx264"
    , "-c:a"
    , "aac"
    ]

loopCleanup :: String -> Aff Unit
loopCleanup filename = liftEffect do
  filepathMp4 <- mp4 filename
  filepathTempVideo <- tempVideo filename
  log $ "[Loop] delete source video: " <> show filepathMp4
  FSSync.rm filepathMp4
  log $ "[Loop] rename " <> show filepathTempVideo <> " into " <> show filepathMp4
  FSSync.rename filepathTempVideo filepathMp4
