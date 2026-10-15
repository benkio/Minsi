module Test.Command.Id3v2Spec where

import Prelude

import Command.Id3v2 (addId3TagsArgs)
import Config (currentVersion)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "addId3TagsArgs" do
    it "should include TSSE so ffprobe exposes Minsi as encoder metadata" do
      addId3TagsArgs "output.mp3" "Pino Scotto" "Sforzi Fabbrica Oasis" `shouldEqual`
        [ "-a"
        , "\"Pino Scotto\""
        , "-t"
        , "\"Sforzi Fabbrica Oasis\""
        , "--TSSE"
        , "\"Minsi-" <> currentVersion <> "\""
        , "output.mp3"
        ]
