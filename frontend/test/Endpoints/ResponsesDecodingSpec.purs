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
        json = """{ "status": "Pending", "description": "some description"  }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse(Pending) to decode, but got error: " <> show err
        Right { status , description } -> do
          status `shouldEqual` "Pending"
          description `shouldEqual` "some description"

    it "decodes StatusResponse.status = Succeed" do
      let
        json = """{ "status": "Succeed", "description": "some description"  }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse(Succeed) to decode, but got error: " <> show err
        Right { status, description } -> do
          status `shouldEqual` "Succeed"
          description `shouldEqual` "some description"

    it "decodes StatusResponse.status = Failed" do
      let
        json = """{ "status": "Failed", "description": "some description"   }"""
        res = (readJSON json :: Either _ StatusResponse)
      case res of
        Left err -> fail $ "Expected StatusResponse(Failed) to decode, but got error: " <> show err
        Right { status, description } -> do
          status `shouldEqual` "Failed"
          description `shouldEqual` "some description"
