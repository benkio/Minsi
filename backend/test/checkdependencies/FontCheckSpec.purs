module Test.CheckDependencies.FontCheckSpec where

import Prelude

import CheckDependencies.FontCheck (searchFont, searchFontInDir, checkFileMatch)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldReturn, shouldEqual)

spec :: Spec Unit
spec = do
  describe "searchFont" do
    it "should find the Impact and Arial Black font" $ liftEffect $ do
      (searchFont "Impact") `shouldReturn` true
      (searchFont "Arial Black") `shouldReturn` true
  describe "checkFileMatch" do
    it "should match a file if it's contained in the path" $ liftEffect $ do
      checkFileMatch "Impact" "/Library/Fonts/Nix Fonts/099js5njycj2qsq7yq3lkvdd68pnifbc-corefonts-1/share/fonts/truetype/Impact.ttf" `shouldEqual` true
      checkFileMatch "Arial Black" "/Library/Fonts/Nix Fonts/099js5njycj2qsq7yq3lkvdd68pnifbc-corefonts-1/share/fonts/truetype/Arial_Black.ttf" `shouldEqual` true
