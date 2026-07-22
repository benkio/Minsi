module Test.Model.StateSpec where

import Prelude

import Data.Either (Either(..), isLeft, isRight)
import Effect.Class (liftEffect)
import Model.State.State (Color(..), DurationRange, Font(..), Position(..), State, Subtitle(..), validateFilename, validateRange, validateState, validateSubtitles)
import Test.Arbitrary (InvalidDurationRange(..), LongerThanNCharacters(..), NonEmptyInvalidDurationRanges(..), NonEmptyValidDurationRanges(..), ValidDurationRange(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Yoga.JSON (readJSON)

spec :: Spec Unit
spec = do
  describe "validateRange" do
    it "returns Left if the duration range is invalid" $ liftEffect $
      quickCheck \(InvalidDurationRange range) -> isLeft (validateRange range)
    it "returns Right if the duration range is valid" $ liftEffect $
      quickCheck \(ValidDurationRange range) -> isRight (validateRange range)
  describe "validateSubtitles" do
    it "returns Right if the subtitles are empty and reverseLoop is true" $ liftEffect $
      (isRight (validateSubtitles (buildSubtitle []) true)) `shouldEqual` true
    it "returns Right if the subtitles are non empty and valid and reverseLoop is false" $ liftEffect $
      quickCheck \(NonEmptyValidDurationRanges ranges) ->
        isRight (validateSubtitles (buildSubtitle ranges) false)
    it "returns Left if the subtitles are not empty and reverseLoop is true" $ liftEffect $
      quickCheck \(NonEmptyValidDurationRanges ranges) ->
        isLeft (validateSubtitles (buildSubtitle ranges) true)
    it "returns Left if the subtitles are not empty and invalid and reverseLoop is false" $ liftEffect $
      quickCheck \(NonEmptyInvalidDurationRanges ranges) ->
        isLeft (validateSubtitles (buildSubtitle ranges) false)
  describe "validateFilename" do
    it "returns Left if the filename is longer then 50 chars" $ liftEffect $
      quickCheck \(LongerThanNCharacters { value }) -> isLeft (validateFilename value)
  describe "validateState" do
    it "accepts a youtube.com live URL source from imported JSON" $ liftEffect $ do
      let
        json =
          """{"uploadLocalFile":true,"title":"Fak These Fakheads","subtitles":[],"source":"https://www.youtube.com/live/vyB7BnvGOE4?t=2130","shiftVideoSync":0,"reverseLoop":false,"filename":"xah_FakTheseFakheads","cutVideo":{"start":2130948,"end":2134189},"artist":"Xah Lee"}"""
      case readJSON json :: Either _ State of
        Left err -> fail ("JSON parse failed: " <> show err)
        Right state -> isRight (validateState state) `shouldEqual` true

buildSubtitle :: Array DurationRange -> Array Subtitle
buildSubtitle ranges =
  map (\videoPosition -> Subtitle { videoPosition, value: "", font: Impact, fontSize: 24, color: White, screenPosition: Bottom }) ranges
