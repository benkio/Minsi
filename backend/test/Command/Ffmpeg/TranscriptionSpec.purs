module Test.Command.Ffmpeg.TranscriptionSpec where

import Prelude

import Command.Ffmpeg.Transcription (subtitleToEnphasisChar, subtitleToMarkdown, subtitlesToMarkdown)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (Color(..), DurationRange(..), Font(..), Position(..), Subtitle(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

mkSubtitle :: String -> Font -> Color -> Subtitle
mkSubtitle value font color =
  Subtitle
    { videoPosition: DurationRange { start: Milliseconds 0.0, end: Milliseconds 1000.0 }
    , value
    , font
    , fontSize: 24
    , color
    , screenPosition: Top
    }

spec :: Spec Unit
spec = do
  describe "subtitleToEnphasisChar" do
    it "returns underscore for ArialBlack + Yellow" do
      subtitleToEnphasisChar (mkSubtitle "A" ArialBlack Yellow) `shouldEqual` "_"

    it "returns star for ArialBlack + LightOrange" do
      subtitleToEnphasisChar (mkSubtitle "A" ArialBlack LightOrange) `shouldEqual` "*"

    it "returns backtick for ArialBlack + LightGreen" do
      subtitleToEnphasisChar (mkSubtitle "A" ArialBlack LightGreen) `shouldEqual` "`"

    it "returns empty string for other combinations" do
      subtitleToEnphasisChar (mkSubtitle "A" Impact White) `shouldEqual` ""

  describe "subtitleToMarkdown" do
    it "wraps subtitle text with matching emphasis marker" do
      subtitleToMarkdown (mkSubtitle "hello" ArialBlack Yellow) `shouldEqual` "_hello_"

    it "leaves subtitle text unchanged when no emphasis marker applies" do
      subtitleToMarkdown (mkSubtitle "hello" Impact White) `shouldEqual` "hello"

  describe "subtitlesToMarkdown" do
    it "joins markdown subtitles with spaces preserving order" do
      let
        subtitles =
          [ mkSubtitle "first" Impact White
          , mkSubtitle "second" ArialBlack LightOrange
          , mkSubtitle "third" ArialBlack LightGreen
          ]
      subtitlesToMarkdown subtitles `shouldEqual` "first *second* `third`"
