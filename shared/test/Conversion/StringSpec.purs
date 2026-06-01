module Test.Conversion.StringSpec where

import Prelude

import Conversion.String (capitalize, capitalizeFirst)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "capitalizeFirst" do
    it "capitalizes first character" $
      capitalizeFirst "hello" `shouldEqual` "Hello"

    it "leaves already capitalized string unchanged" $
      capitalizeFirst "World" `shouldEqual` "World"

    it "handles single character" $
      capitalizeFirst "a" `shouldEqual` "A"

    it "handles empty string" $
      capitalizeFirst "" `shouldEqual` ""

  describe "capitalize" do
    it "capitalizes each word" $
      capitalize "hello world" `shouldEqual` "Hello World"

    it "handles single word" $
      capitalize "hello" `shouldEqual` "Hello"

    it "handles already capitalized words" $
      capitalize "Hello World" `shouldEqual` "Hello World"

    it "handles multiple spaces between words" $
      capitalize "a b c" `shouldEqual` "A B C"

    it "handles empty string" $
      capitalize "" `shouldEqual` ""
