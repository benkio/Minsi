module Test.Contracts.ApiSpec where

import Contracts.Api (CheckDependenciesResponse, StatusResponse, UpdateCheckResponse)
import Data.Either (Either(..))
import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Yoga.JSON (readJSON, writeJSON)

spec :: Spec Unit
spec = do
  describe "API contract JSON encoding" do
    it "encodes StatusResponse" do
      let json = writeJSON ({ status: "Succeed", description: "" } :: StatusResponse)
      json `shouldEqual` """{"status":"Succeed","description":""}"""

    it "encodes CheckDependenciesResponse" do
      let json = writeJSON ({ missedDependencies: [ "ffmpeg", "yt-dlp" ] } :: CheckDependenciesResponse)
      json `shouldEqual` """{"missedDependencies":["ffmpeg","yt-dlp"]}"""

    it "encodes UpdateCheckResponse" do
      let
        json =
          writeJSON
            ( { updateAvailable: true
              , currentVersion: "1.0.0"
              , latestVersion: "1.1.0"
              } :: UpdateCheckResponse
            )
      json `shouldEqual` """{"updateAvailable":true,"latestVersion":"1.1.0","currentVersion":"1.0.0"}"""

  describe "API contract JSON decoding" do
    it "decodes CheckDependenciesResponse" do
      let
        json = """{ "missedDependencies": ["ffmpeg","yt-dlp"] }"""
        res = (readJSON json :: Either _ CheckDependenciesResponse)
      case res of
        Left err -> fail $ "Expected CheckDependenciesResponse to decode, but got error: " <> show err
        Right { missedDependencies } ->
          missedDependencies `shouldEqual` [ "ffmpeg", "yt-dlp" ]

    it "decodes StatusResponse with Pending status" do
      let
        json = """{ "status": "Pending", "description": "some description" }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse to decode, but got error: " <> show err
        Right { status, description } -> do
          status `shouldEqual` "Pending"
          description `shouldEqual` "some description"

    it "decodes StatusResponse with Succeed status" do
      let
        json = """{ "status": "Succeed", "description": "some description" }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse to decode, but got error: " <> show err
        Right { status, description } -> do
          status `shouldEqual` "Succeed"
          description `shouldEqual` "some description"

    it "decodes StatusResponse with Failed status" do
      let
        json = """{ "status": "Failed", "description": "some description" }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse to decode, but got error: " <> show err
        Right { status, description } -> do
          status `shouldEqual` "Failed"
          description `shouldEqual` "some description"
