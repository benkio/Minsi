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
      normalizeVideoArgs "input.mp4" "output.mp4" (Milliseconds 0.0) `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-i"
        , "\"input.mp4\""
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-af"
        , "\"loudnorm=I=-16:TP=-1.5:LRA=11\""
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "\"output.mp4\""
        ]

    it "should delay video when shiftVideoSync is positive" do
      normalizeVideoArgs "input.mp4" "output.mp4" (Milliseconds 1500.0) `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-itsoffset"
        , "1.5"
        , "-i"
        , "\"input.mp4\""
        , "-i"
        , "\"input.mp4\""
        , "-map"
        , "1:a"
        , "-map"
        , "0:v"
        , "-ss"
        , "00:00:01.500"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-af"
        , "\"loudnorm=I=-16:TP=-1.5:LRA=11\""
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "\"output.mp4\""
        ]

    it "should delay audio when shiftVideoSync is negative" do
      normalizeVideoArgs "input.mp4" "output.mp4" (Milliseconds (-500.0)) `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-itsoffset"
        , "-0.5"
        , "-i"
        , "\"input.mp4\""
        , "-i"
        , "\"input.mp4\""
        , "-map"
        , "1:a"
        , "-map"
        , "0:v"
        , "-ss"
        , "00:00:00.500"
        , "-c:v"
        , "libx264"
        , "-c:a"
        , "aac"
        , "-af"
        , "\"loudnorm=I=-16:TP=-1.5:LRA=11\""
        , "-metadata"
        , "encoding_tool=Minsi-" <> currentVersion
        , "\"output.mp4\""
        ]
