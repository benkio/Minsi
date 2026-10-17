module Test.Controller.TranscriptControllerSpec where

import Prelude

import Controller.TranscriptController (isValidTranscriptFilename)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "isValidTranscriptFilename" do
    it "accepts valid output names" do
      isValidTranscriptFilename "abc_Hello1" `shouldEqual` true

    it "rejects path traversal candidates" do
      isValidTranscriptFilename "../evil" `shouldEqual` false
      isValidTranscriptFilename "abc_../../evil" `shouldEqual` false

    it "rejects invalid casing/spacing" do
      isValidTranscriptFilename "abc_hello world" `shouldEqual` false
      isValidTranscriptFilename "Abc_Hello" `shouldEqual` false
