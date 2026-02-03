module Command.Ffmpeg.Mp3 where

import Prelude

import Command.Command (runCommand)
import Constants (mp3, mp4)

import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import MinsiError (MinsiError(..))
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

extractMp3 :: FilePath -> Aff ExecaResult
extractMp3 filename = do
  filepathMp3 <- liftEffect $ mp3 filename
  filepathMp4 <- liftEffect $ mp4 filename
  let args = extractMp3CommandArgs filepathMp3 filepathMp4
  process <- runCommand args FfmpegMp3Error "ffmpeg"
  process.getResult

extractMp3CommandArgs :: FilePath -> FilePath -> Array String
extractMp3CommandArgs filepathMp3 filepathMp4 =
  [ "-hide_banner", "-loglevel", "warning", "-i", filepathMp4, "-vn", "-acodec", "libmp3lame", "-y", filepathMp3 ]
