module Test.CheckDependencies.SoftwareCheckSpec where

import Prelude

import CheckDependencies.SoftwareCheck (checkSoftwareDependency)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldReturn)

spec :: Spec Unit
spec = do
    describe "checkSoftwareDependency" do
        it "should find ffmpeg in PATH" $ liftEffect $ do
            (checkSoftwareDependency "ffmpeg") `shouldReturn` true
        it "should return false if the input is not a valid command" $ liftEffect $ do
            checkSoftwareDependency "not a valid command" `shouldReturn` false
