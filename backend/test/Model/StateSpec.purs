module Test.Model.StateSpec where

import Data.Either (isLeft, isRight)
import Effect.Class (liftEffect)
import Model.State (DurationRange, Subtitle(..), validateRange, validateSubtitles, Font(..), Color(..), Position(..))
import Prelude
import Test.Arbitrary (InvalidDurationRange(..), NonEmptyInvalidDurationRanges(..), NonEmptyValidDurationRanges(..), ValidDurationRange(..))
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

buildSubtitle :: Array DurationRange -> Array Subtitle
buildSubtitle ranges =
  map (\videoPosition -> Subtitle { videoPosition, value: "", font: Impact, fontSize: 24, color: White, screenPosition: Bottom }) ranges

