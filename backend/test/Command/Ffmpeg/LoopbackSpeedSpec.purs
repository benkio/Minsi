module Test.Command.Ffmpeg.LoopbackSpeedSpec where

import Prelude

import Command.Ffmpeg.LoopbackSpeed (buildAtempoArg, clampSpeed, loopbackSpeedArgs)
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
        , "-vf"
        , "setpts=PTS/1.0"
        , "-af"
        , "atempo=1.0,loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "output.mp4"
        ]

  describe "clampSpeed" do
    it "clamps low values to 0.25" $
      clampSpeed 0.0 `shouldEqual` 0.25

    it "clamps high values to 4.0" $
      clampSpeed 9.0 `shouldEqual` 4.0

    it "keeps values in range unchanged" $
      clampSpeed 1.5 `shouldEqual` 1.5

  describe "buildAtempoArg" do
    it "builds a two-stage chain for very slow speed" $
      buildAtempoArg 0.25 `shouldEqual` "atempo=0.5,atempo=0.5"

    it "builds single-stage atempo in normal range" $
      buildAtempoArg 1.5 `shouldEqual` "atempo=1.5"

    it "builds a two-stage chain for fast speed" $
      buildAtempoArg 4.0 `shouldEqual` "atempo=2.0,atempo=2.0"

    it "should support fast speeds with chained atempo filters" do
      loopbackSpeedArgs "input.mp4" "output.mp4" 4.0 `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-i"
        , "input.mp4"
        , "-vf"
        , "setpts=PTS/4.0"
        , "-af"
        , "atempo=2.0,atempo=2.0,loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "output.mp4"
        ]
