module Test.Command.FfmpegSpec where

import Prelude

import Command.Ffmpeg.Mp3 (millisToString, millisecondsToSecondsString, secondsToString)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "secondsToString" do
    it "formats zero seconds" do
      secondsToString 0 `shouldEqual` "00:00:00"

    it "formats seconds less than a minute" do
      secondsToString 5 `shouldEqual` "00:00:05"
      secondsToString 30 `shouldEqual` "00:00:30"
      secondsToString 59 `shouldEqual` "00:00:59"

    it "formats minutes" do
      secondsToString 60 `shouldEqual` "00:01:00"
      secondsToString 90 `shouldEqual` "00:01:30"
      secondsToString 3599 `shouldEqual` "00:59:59"

    it "formats hours" do
      secondsToString 3600 `shouldEqual` "01:00:00"
      secondsToString 3661 `shouldEqual` "01:01:01"
      secondsToString 7323 `shouldEqual` "02:02:03"

    it "formats large values" do
      secondsToString 86400 `shouldEqual` "24:00:00"
      secondsToString 90061 `shouldEqual` "25:01:01"

  describe "millisToString" do
    it "formats zero milliseconds with comma separator" do
      millisToString (Milliseconds 0.0) ',' `shouldEqual` "00:00:00,000"

    it "formats milliseconds less than a second" do
      millisToString (Milliseconds 123.0) ',' `shouldEqual` "00:00:00,123"
      millisToString (Milliseconds 999.0) ',' `shouldEqual` "00:00:00,999"

    it "formats seconds with milliseconds" do
      millisToString (Milliseconds 1000.0) ',' `shouldEqual` "00:00:01,000"
      millisToString (Milliseconds 1234.0) ',' `shouldEqual` "00:00:01,234"
      millisToString (Milliseconds 59999.0) ',' `shouldEqual` "00:00:59,999"

    it "formats minutes with milliseconds" do
      millisToString (Milliseconds 60000.0) ',' `shouldEqual` "00:01:00,000"
      millisToString (Milliseconds 61000.0) ',' `shouldEqual` "00:01:01,000"
      millisToString (Milliseconds 61234.0) ',' `shouldEqual` "00:01:01,234"

    it "formats hours with milliseconds" do
      millisToString (Milliseconds 3600000.0) ',' `shouldEqual` "01:00:00,000"
      millisToString (Milliseconds 3661234.0) ',' `shouldEqual` "01:01:01,234"

    it "formats with different separators" do
      millisToString (Milliseconds 1234.0) '.' `shouldEqual` "00:00:01.234"
      millisToString (Milliseconds 1234.0) '|' `shouldEqual` "00:00:01|234"
      millisToString (Milliseconds 1234.0) ' ' `shouldEqual` "00:00:01 234"

    it "handles fractional milliseconds by flooring" do
      millisToString (Milliseconds 1234.7) ',' `shouldEqual` "00:00:01,234"
      millisToString (Milliseconds 1234.9) ',' `shouldEqual` "00:00:01,234"

    it "handles large millisecond values" do
      millisToString (Milliseconds 86400000.0) ',' `shouldEqual` "24:00:00,000"
      millisToString (Milliseconds 90061000.0) ',' `shouldEqual` "25:01:01,000"

  describe "millisecondsToSecondsString" do
    it "uses comma separator when Nothing is provided" do
      millisecondsToSecondsString (Milliseconds 1234.0) Nothing `shouldEqual` "00:00:01,234"
      millisecondsToSecondsString (Milliseconds 0.0) Nothing `shouldEqual` "00:00:00,000"

    it "uses provided separator when Just char is provided" do
      millisecondsToSecondsString (Milliseconds 1234.0) (Just '.') `shouldEqual` "00:00:01.234"
      millisecondsToSecondsString (Milliseconds 1234.0) (Just '|') `shouldEqual` "00:00:01|234"
      millisecondsToSecondsString (Milliseconds 1234.0) (Just ' ') `shouldEqual` "00:00:01 234"

    it "handles various time values with default separator" do
      millisecondsToSecondsString (Milliseconds 3661234.0) Nothing `shouldEqual` "01:01:01,234"
      millisecondsToSecondsString (Milliseconds 90061000.0) Nothing `shouldEqual` "25:01:01,000"
