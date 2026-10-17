module Test.Handlers.CopyTranscriptButtonHandlerSpec where

import Prelude

import Handlers.CopyTranscriptButtonHandler (isStaleTranscriptRequest)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "isStaleTranscriptRequest" do
    it "returns false when request and current filename match" do
      isStaleTranscriptRequest "abc_Hello" "abc_Hello" `shouldEqual` false

    it "returns true when selected transcript changed during request" do
      isStaleTranscriptRequest "abc_Hello" "abc_Other" `shouldEqual` true
