module Test.Conversion.OutputFilenameSpec where

import Prelude

import Conversion.OutputFilename (normalizeOutputFilename)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "normalizeOutputFilename" do
    it "capitalizes first character when no known prefix" $
      normalizeOutputFilename "myfile" `shouldEqual` "Myfile"

    it "preserves known prefix and capitalizes the rest" $
      normalizeOutputFilename "rphjb_hello" `shouldEqual` "rphjb_Hello"

    it "handles prefix-only input" $
      normalizeOutputFilename "rphjb_" `shouldEqual` "rphjb_"

    it "capitalizes single character input" $
      normalizeOutputFilename "a" `shouldEqual` "A"

    it "handles already capitalized input" $
      normalizeOutputFilename "Already" `shouldEqual` "Already"
