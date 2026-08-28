module Test.Contracts.ApiSpec where

import Contracts.Api (CheckDependenciesResponse, StatusResponse, UpdateCheckResponse, WhisperSubtitlesResponse)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (Color(..), DurationRange(..), Font(..), Position(..), Subtitle(..))
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

    it "encodes WhisperSubtitlesResponse" do
      let
        subtitle1 =
          Subtitle
            { videoPosition: DurationRange { start: Milliseconds 10.0, end: Milliseconds 20.0 }
            , value: "ciao mondo"
            , font: Impact
            , fontSize: 24
            , color: White
            , screenPosition: Top
            }
        subtitle2 =
          Subtitle
            { videoPosition: DurationRange { start: Milliseconds 20.0, end: Milliseconds 30.0 }
            , value: "arrivederci"
            , font: Impact
            , fontSize: 24
            , color: White
            , screenPosition: Top
            }
        json =
          writeJSON
            ( { subtitles: [ subtitle1, subtitle2 ] } :: WhisperSubtitlesResponse
            )
      json `shouldEqual` """{"subtitles":[{"videoPosition":{"start":10,"end":20},"value":"ciao mondo","screenPosition":"Top","fontSize":24,"font":"Impact","color":"#ffffff"},{"videoPosition":{"start":20,"end":30},"value":"arrivederci","screenPosition":"Top","fontSize":24,"font":"Impact","color":"#ffffff"}]}"""

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

    it "decodes WhisperSubtitlesResponse" do
      let
        json = """{ "subtitles": [ { "videoPosition": { "start": 1000, "end": 2000 }, "value": "ciao", "font": "Impact", "fontSize": 24, "color": "#ffffff", "screenPosition": "Top" } ] }"""
        res = (readJSON json :: Either _ WhisperSubtitlesResponse)
      case res of
        Left err -> fail $ "Expected WhisperSubtitlesResponse to decode, but got error: " <> show err
        Right { subtitles } ->
          subtitles `shouldEqual`
            [ Subtitle
                { videoPosition: DurationRange { start: Milliseconds 1000.0, end: Milliseconds 2000.0 }
                , value: "ciao"
                , font: Impact
                , fontSize: 24
                , color: White
                , screenPosition: Top
                }
            ]
