module Test.CheckDependencies.SoftwareCheckSpec where

import CheckDependencies.SoftwareCheck (checkSoftwareDependency, checkSoftwareDependencies)
import Data.Array (elem)
import Effect.Class (liftEffect)
import Prelude
import Test.Main (isNotCI)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldReturn)

spec :: Spec Unit
spec = do
  describe "checkSoftwareDependency" do
    it "should find ffmpeg in PATH" $ liftEffect $ whenM isNotCI ((checkSoftwareDependency "ffmpeg") `shouldReturn` true)
    it "should find yt-dlp in PATH" $ liftEffect $ whenM isNotCI ((checkSoftwareDependency "yt-dlp") `shouldReturn` true)
    it "should find id3v2 in PATH" $ liftEffect $ whenM isNotCI ((checkSoftwareDependency "id3v2") `shouldReturn` true)
    it "should find fc-list in PATH" $ liftEffect $ whenM isNotCI ((checkSoftwareDependency "fc-list") `shouldReturn` true)
    it "should return false if the input is not a valid command" $ liftEffect $
      checkSoftwareDependency "not a valid command" `shouldReturn` false
  describe "checkSoftwareDependencies" do
    it "includes whisper when dependency is missing" $ liftEffect do
      hasWhisper <- checkSoftwareDependency "whisper"
      missing <- checkSoftwareDependencies
      (elem "whisper" missing) `shouldEqual` not hasWhisper
