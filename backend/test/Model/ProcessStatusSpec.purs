module Test.Model.ProcessStatusSpec where

import Prelude

import Model.ProcessStatus (ProcessStatus(..), isFinished)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "isFinished" do
    it "returns false for Pending" do
      isFinished Pending `shouldEqual` false

    it "returns true for Succeed" do
      isFinished Succeed `shouldEqual` true

    it "returns true for Failed" do
      isFinished (Failed "") `shouldEqual` true
