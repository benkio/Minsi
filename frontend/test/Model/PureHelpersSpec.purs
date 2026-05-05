module Test.Model.PureHelpersSpec where

import Prelude

import Data.Time.Duration (Milliseconds(..))
import Handlers.ResultMedia.MediaSrc (isVideoSource)
import Handlers.Subtitles.SubtitleMaxValues (durationMillis)
import Model.State.State (DurationRange(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "isVideoSource" do
    it "returns true for mp4" $
      isVideoSource "mp4" `shouldEqual` true

    it "returns true for gif" $
      isVideoSource "gif" `shouldEqual` true

    it "returns false for mp3" $
      isVideoSource "mp3" `shouldEqual` false

    it "returns false for unknown" $
      isVideoSource "wav" `shouldEqual` false

  describe "durationMillis" do
    it "computes duration from range" $
      durationMillis (DurationRange { start: Milliseconds 1000.0, end: Milliseconds 5000.0 }) `shouldEqual` 4000.0

    it "returns zero for equal start and end" $
      durationMillis (DurationRange { start: Milliseconds 500.0, end: Milliseconds 500.0 }) `shouldEqual` 0.0
