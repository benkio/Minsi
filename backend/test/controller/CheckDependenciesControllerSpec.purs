module Test.Controller.CheckDependenciesControllerSpec where

import Prelude

import Controller.CheckDependenciesController (checkSoftwareDependency, fcListSearch)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldReturn)

spec :: Spec Unit
spec = do
    describe "fcListSearch" do
        it "should find the Impact font" $ liftEffect $ do
            (fcListSearch "Impact") `shouldReturn` true
    describe "checkSoftwareDependency" do
        it "should find ffmpeg in PATH" $ liftEffect $ do
            (checkSoftwareDependency "ffmpeg") `shouldReturn` true
        it "should return false if the input is not a valid command" $ liftEffect $ do
            checkSoftwareDependency "not a valid command" `shouldReturn` false
