module Test.Controller.CheckDependenciesControllerSpec where

import Prelude

import Controller.CheckDependenciesController (checkSoftwareDependency, searchFont, searchFontInDir, checkFileMatch)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldReturn, shouldEqual)

spec :: Spec Unit
spec = do
    describe "searchFont" do
        it "should find the Impact and Arial Black font" $ liftEffect $ do
            (searchFont "Impact") `shouldReturn` true
            (searchFont "Arial Black") `shouldReturn` true
    describe "checkSoftwareDependency" do
        it "should find ffmpeg in PATH" $ liftEffect $ do
            (checkSoftwareDependency "ffmpeg") `shouldReturn` true
        it "should return false if the input is not a valid command" $ liftEffect $ do
            checkSoftwareDependency "not a valid command" `shouldReturn` false
    describe "searchFontInDir" do
        it "should find the Impact font in /Library/fonts/" $ liftEffect $ do
          searchFontInDir "Impact" "/Library/Fonts" `shouldReturn` true
    describe "checkFileMatch" do
        it "should match a file if it's contained in the path" $ liftEffect $ do
          checkFileMatch "Impact" "/Library/Fonts/Nix Fonts/099js5njycj2qsq7yq3lkvdd68pnifbc-corefonts-1/share/fonts/truetype/Impact.ttf" `shouldEqual` true
          checkFileMatch "Arial Black" "/Library/Fonts/Nix Fonts/099js5njycj2qsq7yq3lkvdd68pnifbc-corefonts-1/share/fonts/truetype/Arial_Black.ttf" `shouldEqual` true
