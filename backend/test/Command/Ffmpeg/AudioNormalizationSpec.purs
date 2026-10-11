module Test.Command.Ffmpeg.AudioNormalizationSpec where

import Prelude

import Command.Ffmpeg.AudioNormalization (normalizeAudioArgs)
import Config (currentVersion)
import Data.Time.Duration (Milliseconds(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "normalizeAudioArgs" do
    it "should not apply a shift when shiftVideoSync is zero" do
      normalizeAudioArgs "input.mp4" "output.mp4" (Milliseconds 0.0) `shouldEqual`
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
      normalizeAudioArgs "input.mp4" "output.mp4" (Milliseconds 1500.0) `shouldEqual`
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
      normalizeAudioArgs "input.mp4" "output.mp4" (Milliseconds (-500.0)) `shouldEqual`
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
