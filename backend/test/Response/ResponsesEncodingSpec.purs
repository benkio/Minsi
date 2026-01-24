module Test.Response.ResponsesEncodingSpec where

import Prelude

import Model.ProcessStatus (ProcessStatus(..))
import Response.CheckDependenciesResponse (buildResponse) as CheckDependenciesResponse
import Response.ComputeResponse (buildResponse) as ComputeResponse
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Yoga.JSON (writeJSON)

spec :: Spec Unit
spec = do
  describe "Response JSON encoding" do
    it "encodes ComputeResponse" do
      let json = writeJSON (ComputeResponse.buildResponse Succeed)
      json `shouldEqual` """{"status":"Succeed"}"""

    it "encodes CheckDependenciesResponse" do
      let json = writeJSON (CheckDependenciesResponse.buildResponse [ "ffmpeg", "yt-dlp" ])
      json `shouldEqual` """{"missedDependencies":["ffmpeg","yt-dlp"]}"""

