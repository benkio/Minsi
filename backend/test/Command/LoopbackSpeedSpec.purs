module Test.Command.LoopbackSpeedSpec where

import Prelude

import Command.Ffmpeg.LoopbackSpeed (loopbackSpeedArgs)
import Config (currentVersion)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "loopbackSpeedArgs" do
    it "should keep normal speed when loopbackSpeed is 1" do
      loopbackSpeedArgs "input.mp4" "output.mp4" 1.0 `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-i"
        , "input.mp4"
        , "-filter_complex"
        , "[0:v]setpts=PTS/1.0[v];[0:a]atempo=1.0,loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true[a]"
        , "-map"
        , "[v]"
        , "-map"
        , "[a]"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "output.mp4"
        ]

    it "should support fast speeds with chained atempo filters" do
      loopbackSpeedArgs "input.mp4" "output.mp4" 4.0 `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-i"
        , "input.mp4"
        , "-filter_complex"
        , "[0:v]setpts=PTS/4.0[v];[0:a]atempo=2.0,atempo=2.0,loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true[a]"
        , "-map"
        , "[v]"
        , "-map"
        , "[a]"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "output.mp4"
        ]
