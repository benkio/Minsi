module Command.Ffmpeg.AudioNormalization where

import Prelude

import Command.Command (runCommand)
import Command.Ffmpeg.Base (baseFlagsInput, baseFlagsOutput)
import Constants (mp4, tempVideo)
import Conversion.Time (millisecondsToSecondsString)
import Data.Maybe (Maybe(..))
import Data.Number (abs)
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (Aff, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..))
import Node.FS.Sync as FSSync
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

audioNormalizationTimeout :: Maybe Milliseconds
audioNormalizationTimeout = Nothing

normalizeAudio :: FilePath -> Milliseconds -> Aff ExecaResult
normalizeAudio filename shiftVideoSync = do
  finally (audioNormalizationCleanup filename) (makeNormalizeAudio filename shiftVideoSync)

makeNormalizeAudio :: FilePath -> Milliseconds -> Aff ExecaResult
makeNormalizeAudio filename shiftVideoSync = do
  args <- liftEffect $ normalizeAudioArgs <$> mp4 filename <*> tempVideo filename <*> pure shiftVideoSync
  process <- runCommand audioNormalizationTimeout args FfmpegVideoError "ffmpeg"
  process.getResult

normalizeAudioArgs :: FilePath -> FilePath -> Milliseconds -> Array String
normalizeAudioArgs mp4 tempVideo (Milliseconds shiftVideoSync) =
  baseFlagsInput <> inputFlags <> passthroughAudioFlags <> codecFlags <> baseFlagsOutput <> [ tempVideo ]
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

millisecondsToOffsetSeconds :: Number -> String
millisecondsToOffsetSeconds ms = show (ms / 1000.0)

audioNormalizationCleanup :: String -> Aff Unit
audioNormalizationCleanup filename = liftEffect do
  filepathMp4 <- mp4 filename
  filepathTempVideo <- tempVideo filename
  log $ "[AudioNormalization] delete source video: " <> show filepathMp4
  FSSync.rm filepathMp4
  log $ "[AudioNormalization] rename " <> show filepathTempVideo <> " into " <> show filepathMp4
  FSSync.rename filepathTempVideo filepathMp4
