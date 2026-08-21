module Command.OpenAIWhisper where

import Prelude

import Command.Command (runCommand)
import Constants (mp3, outputPath)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Model.State.SubtitleConstraints (maxSubtitleCharsPerLine)
import MinsiErrors (MinsiError(..))
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

maxSubtitleLinesPerSegment :: Int
maxSubtitleLinesPerSegment = 1

generateJson :: FilePath -> Aff ExecaResult
generateJson filename = do
  args <- liftEffect $ generateJsonArgs <$> mp3 filename <*> outputPath
  process <- runCommand args OpenAIWhisperError "whisper"
  process.getResult

generateJsonArgs :: FilePath -> FilePath -> Array String
generateJsonArgs filepathMp3 outputDir =
  [ filepathMp3
  , "--model", "small"
  , "--language", "it"
  , "--task", "transcribe"
  , "--output_format", "json"
  , "--output_dir", outputDir
  , "--word_timestamps", "True"
  , "--max_line_width", show maxSubtitleCharsPerLine
  , "--max_line_count", show maxSubtitleLinesPerSegment
  , "--verbose", "False"
  ]
