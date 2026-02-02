module Test.Endpoints.ResponsesDecodingSpec where

import Prelude

import Data.Either (Either(..))
import Endpoints.CheckDependencies (MissingDependenciesResponse)
import Endpoints.Status (StatusResponse)
import Model.ProcessStatus (ProcessStatus(..))
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

    it "decodes StatusResponse.status = Pending" do
      let
        json = """{ "status": "Pending" }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse(Pending) to decode, but got error: " <> show err
        Right { status } ->
          status `shouldEqual` Pending

    it "decodes StatusResponse.status = Succeed" do
      let
        json = """{ "status": "Succeed" }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse(Succeed) to decode, but got error: " <> show err
        Right { status } ->
          status `shouldEqual` Succeed

    it "decodes StatusResponse.status = Failed" do
      let
        json = """{ "status": "Failed: " }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse(Failed) to decode, but got error: " <> show err
        Right { status } ->
          status `shouldEqual` Failed ""

    it "decodes StatusResponse.status = Failed with error message" do
      let
        json = """{ "status": "Failed: video processing error" }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse(Failed with message) to decode, but got error: " <> show err
        Right { status } ->
          status `shouldEqual` Failed "video processing error"

