module Test.Endpoints.ResponsesDecodingSpec where

import Data.Either (Either(..))
import Endpoints.CheckDependencies (MissingDependenciesResponse)
import Endpoints.Compute (ComputeResponse)
import Model.ProcessStatus (ProcessStatus(..))
import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Yoga.JSON (readJSON)

spec :: Spec Unit
spec = do
  describe "Endpoints JSON decoding" do
    it "decodes MissingDependenciesResponse" do
      let
        json = """{ "missedDependencies": ["ffmpeg","yt-dlp"] }"""
        res = (readJSON json :: Either _ MissingDependenciesResponse)
      case res of
        Left err -> fail $ "Expected MissingDependenciesResponse to decode, but got error: " <> show err
        Right { missedDependencies } ->
          missedDependencies `shouldEqual` [ "ffmpeg", "yt-dlp" ]

    it "decodes ComputeResponse.status = Pending" do
      let
        json = """{ "status": "Pending" }"""
        res = (readJSON json :: Either _ ComputeResponse)
      case res of
        Left err -> fail $ "Expected ComputeResponse(Pending) to decode, but got error: " <> show err
        Right { status } ->
          status `shouldEqual` Pending

    it "decodes ComputeResponse.status = Succeed" do
      let
        json = """{ "status": "Succeed" }"""
        res = (readJSON json :: Either _ ComputeResponse)
      case res of
        Left err -> fail $ "Expected ComputeResponse(Succeed) to decode, but got error: " <> show err
        Right { status } ->
          status `shouldEqual` Succeed

    it "decodes ComputeResponse.status = Failed" do
      let
        json = """{ "status": "Failed" }"""
        res = (readJSON json :: Either _ ComputeResponse)
      case res of
        Left err -> fail $ "Expected ComputeResponse(Failed) to decode, but got error: " <> show err
        Right { status } ->
          status `shouldEqual` Failed

