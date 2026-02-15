module Test.Parse.FontSpec where

import Model.State.State (Font(..), Color(..), Position(..))
import Parse.Font (parseFontAndColor, parsePosition)
import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "parseFontAndColor" do
    it "parses Impact with Black" do
      parseFontAndColor "ImpactBlack" `shouldEqual` { font: Impact, color: Black }
    it "parses Impact with White" do
      parseFontAndColor "ImpactWhite" `shouldEqual` { font: Impact, color: White }
    it "parses ArialBlack with Yellow" do
      parseFontAndColor "ArialBlackYellow" `shouldEqual` { font: ArialBlack, color: Yellow }
    it "parses ArialBlack with LightGreen" do
      parseFontAndColor "ArialBlackLightGreen" `shouldEqual` { font: ArialBlack, color: LightGreen }
    it "parses ArialBlack with LightOrange" do
      parseFontAndColor "ArialBlackLightOrange" `shouldEqual` { font: ArialBlack, color: LightOrange }
    it "defaults to Impact and White for unknown" do
      parseFontAndColor "Other" `shouldEqual` { font: Impact, color: White }
      parseFontAndColor "" `shouldEqual` { font: Impact, color: White }

  describe "parsePosition" do
    it "parses Top" do
      parsePosition "Top" `shouldEqual` Top
    it "defaults to Bottom for unknown position" do
      parsePosition "Bottom" `shouldEqual` Bottom
      parsePosition "Other" `shouldEqual` Bottom
      parsePosition "" `shouldEqual` Bottom
