module Test.Command.VideoSpec where

import Prelude

import Command.Ffmpeg.Video (normalizeVideoArgs)
import Config (currentVersion)
import Data.Time.Duration (Milliseconds(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "normalizeVideoArgs" do
    it "should not apply a shift when shiftVideoSync is zero" do
      normalizeVideoArgs "input.mp4" "output.mp4" (Milliseconds 0.0) false `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-i"
        , "input.mp4"
        , "-af"
        , "loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "output.mp4"
        ]

    it "should delay video when shiftVideoSync is positive" do
      normalizeVideoArgs "input.mp4" "output.mp4" (Milliseconds 1500.0) false `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-itsoffset"
        , "1.5"
        , "-i"
        , "input.mp4"
        , "-i"
        , "input.mp4"
        , "-ss"
        , "00:00:01.500"
        , "-map"
        , "0:v"
        , "-map"
        , "1:a"
        , "-af"
        , "loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "output.mp4"
        ]

    it "should delay audio when shiftVideoSync is negative" do
      normalizeVideoArgs "input.mp4" "output.mp4" (Milliseconds (-500.0)) false `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-itsoffset"
        , "-0.5"
        , "-i"
        , "input.mp4"
        , "-i"
        , "input.mp4"
        , "-ss"
        , "00:00:00.500"
        , "-map"
        , "0:v"
        , "-map"
        , "1:a"
        , "-af"
        , "loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "output.mp4"
        ]

    it "should reverse-loop in one pass when reverseLoop is enabled" do
      normalizeVideoArgs "input.mp4" "output.mp4" (Milliseconds 0.0) true `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-i"
        , "input.mp4"
        , "-filter_complex"
        , "[0:v]split[vfwd][vtmp];[vtmp]reverse[vrev];[vfwd][vrev]concat=n=2:v=1:a=0[v];[0:a]asplit[afwd][atmp];[atmp]areverse[arev];[afwd][arev]concat=n=2:v=0:a=1[aloop];[aloop]loudnorm=I=-16:TP=-1.5:LRA=11:dual_mono=true[a]"
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
