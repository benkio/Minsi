module Test.Parse.FontSpec where

import Model.State.State (Font(..), Color(..), Position(..))
import Parse.Font (parseFont, parseColor, parsePosition)
import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "parseFont" do
    it "parses Arial Black" do
      parseFont "Arial Black" `shouldEqual` ArialBlack
    it "defaults to Impact for unknown font" do
      parseFont "Impact" `shouldEqual` Impact
      parseFont "Other" `shouldEqual` Impact
      parseFont "" `shouldEqual` Impact

  describe "parseColor" do
    it "parses Black" do
      parseColor "Black" `shouldEqual` Black
    it "parses Light Green" do
      parseColor "Light Green" `shouldEqual` LightGreen
    it "parses Light Orange" do
      parseColor "Light Orange" `shouldEqual` LightOrange
    it "parses Yellow" do
      parseColor "Yellow" `shouldEqual` Yellow
    it "defaults to White for unknown color" do
      parseColor "White" `shouldEqual` White
      parseColor "Other" `shouldEqual` White
      parseColor "" `shouldEqual` White

  describe "parsePosition" do
    it "parses Top" do
      parsePosition "Top" `shouldEqual` Top
    it "defaults to Bottom for unknown position" do
      parsePosition "Bottom" `shouldEqual` Bottom
      parsePosition "Other" `shouldEqual` Bottom
      parsePosition "" `shouldEqual` Bottom
