module Test.Model.ProcessStatusSpec where

import Domain.ProcessStatus (ProcessStatus(..), isFinished)
import Prelude
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

  describe "show" do
    it "hides LocalFileUploaded payload in status string" do
      show (LocalFileUploaded "tmp.mp4") `shouldEqual` "LocalFileUploaded"

    it "hides Failed payload in status string" do
      show (Failed "some backend error") `shouldEqual` "Failed"
