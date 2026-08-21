module Test.Command.OpenAIWhisperSpec where

import Prelude

import Command.OpenAIWhisper (generateJsonArgs)
import Model.State.SubtitleConstraints (maxSubtitleCharsPerLine)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "generateJsonArgs" do
    it "builds json-only whisper command arguments from shared constraints" do
      generateJsonArgs "/tmp/input.mp3" "/tmp/out" `shouldEqual`
        [ "/tmp/input.mp3"
        , "--model", "tiny"
        , "--language", "it"
        , "--task", "transcribe"
        , "--output_format", "json"
        , "--output_dir", "/tmp/out"
        , "--word_timestamps", "True"
        , "--max_line_width", show maxSubtitleCharsPerLine
        , "--max_line_count", "1"
        , "--verbose", "False"
        ]

