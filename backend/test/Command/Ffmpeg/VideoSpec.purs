module Test.Command.Ffmpeg.VideoSpec where

import Prelude

import Command.Ffmpeg.Video (FfmpegInput(..), cutAndConvertUpladedVideoArgs)
import Config (currentVersion)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "cutAndConvertUpladedVideoArgs" do
    it "should include start and duration when a cut range is provided" do
      cutAndConvertUpladedVideoArgs "output.mp4"
        ( FfmpegInput
            { input: "input.mov"
            , filename: "ignored"
            , maybeStart: Just (Milliseconds 1000.0)
            , maybeEnd: Just (Milliseconds 3500.0)
            }
        )
        `shouldEqual`
          [ "-hide_banner"
          , "-loglevel"
          , "warning"
          , "-i"
          , "input.mov"
          , "-c:v"
          , "libx264"
          , "-c:a"
          , "aac"
          , "-ss"
          , "00:00:01.000"
          , "-t"
          , "00:00:02.500"
          , "-metadata"
          , "encoding_tool=Minsi-" <> currentVersion
          , "output.mp4"
          ]

    it "should omit start and duration when no cut range is provided" do
      cutAndConvertUpladedVideoArgs "output.mp4"
        ( FfmpegInput
            { input: "input.mov"
            , filename: "ignored"
            , maybeStart: Nothing
            , maybeEnd: Nothing
            }
        )
        `shouldEqual`
          [ "-hide_banner"
          , "-loglevel"
          , "warning"
          , "-i"
          , "input.mov"
          , "-c:v"
          , "libx264"
          , "-c:a"
          , "aac"
          , "-metadata"
          , "encoding_tool=Minsi-" <> currentVersion
          , "output.mp4"
          ]
