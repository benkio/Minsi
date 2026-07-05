module Command.Ffmpeg.Mp3 where

import Prelude

import Command.Command (runCommand)
import Command.Ffmpeg.Base (baseFlags)
import Constants (mp3, mp4)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import MinsiErrors (MinsiError(..))
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

extractMp3 :: FilePath -> Aff ExecaResult
extractMp3 filename = do
  args <- liftEffect $ extractMp3CommandArgs <$> mp3 filename <*> mp4 filename
  process <- runCommand args FfmpegMp3Error "ffmpeg"
  process.getResult

extractMp3CommandArgs :: FilePath -> FilePath -> Array String
extractMp3CommandArgs filepathMp3 filepathMp4 =
  baseFlags <> [ "-i", filepathMp4, "-vn", "-acodec", "libmp3lame", "-y", filepathMp3 ]
