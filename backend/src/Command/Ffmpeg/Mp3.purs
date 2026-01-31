module Command.Ffmpeg.Mp3 where

import Prelude

import Command.Command (runCommand)
import Constants (mp3, mp4)
import Data.Foldable (intercalate)
import Data.Int (floor)
import Data.Maybe (Maybe(..))
import Data.String.CodeUnits (singleton)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import MinsiError (MinsiError(..))
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)
import Text.Printf (formatInt)

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
