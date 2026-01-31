module Test.CheckDependencies.SoftwareCheckSpec where

import Prelude
import CheckDependencies.SoftwareCheck (checkSoftwareDependency, checkSoftwareDependencies)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldReturn)

spec :: Spec Unit
spec = do
  describe "checkSoftwareDependency" do
    it "should find ffmpeg in PATH" $ liftEffect $ (checkSoftwareDependency "ffmpeg") `shouldReturn` true
    it "should find yt-dlp in PATH" $ liftEffect $ (checkSoftwareDependency "yt-dlp") `shouldReturn` true
    it "should find id3v2 in PATH" $ liftEffect $ (checkSoftwareDependency "id3v2") `shouldReturn` true
    it "should find fc-list in PATH" $ liftEffect $ (checkSoftwareDependency "fc-list") `shouldReturn` true
    it "should return false if the input is not a valid command" $ liftEffect $
      checkSoftwareDependency "not a valid command" `shouldReturn` false
  describe "checkSoftwareDependencies" do
    it "should return empty array (if your machine is valid)" $ liftEffect $ checkSoftwareDependencies `shouldReturn` []
