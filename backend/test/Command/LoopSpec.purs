module Test.Command.LoopSpec where

import Prelude

import Command.Ffmpeg.Loop (reverseLoopArgs)
import Config (currentVersion)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "reverseLoopArgs" do
    it "should reverse and concatenate in one pass" do
      reverseLoopArgs "input.mp4" "output.mp4" `shouldEqual`
        [ "-hide_banner"
        , "-loglevel"
        , "warning"
        , "-i"
        , "input.mp4"
        , "-filter_complex"
        , "[0:v]split[vfwd][vtmp];[vtmp]reverse[vrev];[vfwd][vrev]concat=n=2:v=1:a=0[v];[0:a]asplit[afwd][atmp];[atmp]areverse[arev];[afwd][arev]concat=n=2:v=0:a=1[a]"
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
