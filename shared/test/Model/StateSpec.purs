module Test.Model.StateSpec where

import Prelude

import Data.Either (isLeft, isRight)
import Effect.Class (liftEffect)
import Model.State.State (Color(..), DurationRange, Font(..), Position(..), Subtitle(..), validateFilename, validateRange, validateSubtitles)
import Test.Arbitrary (InvalidDurationRange(..), LongerThanNCharacters(..), NonEmptyInvalidDurationRanges(..), NonEmptyValidDurationRanges(..), ValidDurationRange(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

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

buildSubtitle :: Array DurationRange -> Array Subtitle
buildSubtitle ranges =
  map (\videoPosition -> Subtitle { videoPosition, value: "", font: Impact, fontSize: 24, color: White, screenPosition: Bottom }) ranges
