module Test.Command.LoopSpec where

import Prelude

import Command.Ffmpeg.Loop (reverseLoopConcatArgs, reverseLoopReverseArgs)
import Config (currentVersion)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "reverseLoopReverseArgs" do
    it "should build reverse-pass args" do
      reverseLoopReverseArgs "input.mp4" "reversed.mp4" `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-i"
        , "input.mp4"
        , "-vf"
        , "reverse"
        , "-af"
        , "areverse"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "reversed.mp4"
        ]

  describe "reverseLoopConcatArgs" do
    it "should build concat-pass args" do
      reverseLoopConcatArgs "input.txt" "output.mp4" `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-f"
        , "concat"
        , "-safe"
        , "0"
        , "-i"
        , "input.txt"
        , "-c"
        , "copy"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "output.mp4"
        ]
