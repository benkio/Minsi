module Test.Command.Ffmpeg.TranscriptionSpec where

import Prelude

import Command.Ffmpeg.Transcription (applyRestorationThenEscaping, restoreTranscriptGroupedByLineWith, subtitleToEnphasisChar, subtitleToMarkdown, subtitlesToMarkdown, transcriptionErrorDetails, toTranscriptionError)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Effect.Exception (error, message)
import MinsiErrors (MinsiError(..))
import Model.State.State (Color(..), DurationRange(..), Font(..), Position(..), Subtitle(..), subtitlesToString)
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
      subtitlesToMarkdown subtitles `shouldEqual` "first second third"

    it "applies emphasis only once around the full grouped line" do
      let
        subtitles =
          [ mkSubtitle "ah rock" ArialBlack Yellow
          , mkSubtitle "e lento" ArialBlack Yellow
          , mkSubtitle "e quello e quell'altro" ArialBlack Yellow
          ]
      subtitlesToMarkdown subtitles `shouldEqual` "_ah rock e lento e quello e quell'altro_"

    it "does not keep all-caps input when producing markdown transcript lines" do
      let
        subtitles =
          [ mkSubtitle "  HELLO  " Impact White
          , mkSubtitle "  WORLD  " Impact White
          ]
      subtitlesToString subtitles (Just subtitlesToMarkdown) `shouldEqual` "Hello world"

    it "keeps style groups on separate lines in markdown transformation" do
      let
        subtitles =
          [ mkSubtitle "C'è capito la gente" Impact White
          , mkSubtitle "che dice" Impact White
          , mkSubtitle "ah rock" ArialBlack Yellow
          , mkSubtitle "e lento" ArialBlack Yellow
          , mkSubtitle "e quello e quell'altro" ArialBlack Yellow
          , mkSubtitle "fate ridere" Impact White
          ]
      subtitlesToString subtitles (Just subtitlesToMarkdown)
        `shouldEqual`
          "C'è capito la gente che dice\n_ah rock e lento e quello e quell'altro_\nFate ridere"

  describe "transcription error wrapping" do
    it "preserves both exception type rendering and message" do
      let
        e = error "boom"
      transcriptionErrorDetails e `shouldEqual` ("type=" <> show e <> "; message=" <> message e)

    it "wraps exceptions as TranscriptionError" do
      let
        e = error "boom"
      case toTranscriptionError e of
        TranscriptionError details -> details `shouldEqual` ("type=" <> show e <> "; message=" <> message e)
        _ -> "unexpected constructor" `shouldEqual` "TranscriptionError"

  describe "restoration + escaping order" do
    it "applies restoration before escaping" do
      let
        restore = (_ <> " [restored]")
        escape = (_ <> " [escaped]")
      applyRestorationThenEscaping restore escape "hello"
        `shouldEqual` "hello [restored] [escaped]"

    it "applies escaping exactly once in the pipeline function" do
      let
        restore = identity
        escape = (_ <> " [escaped]")
      applyRestorationThenEscaping restore escape "hello"
        `shouldEqual` "hello [escaped]"

  describe "line-group preservation during restoration" do
    it "restores each non-empty line independently and keeps line breaks" do
      let
        fakeRestore line = pure ("[" <> line <> "]")
      result <- restoreTranscriptGroupedByLineWith fakeRestore "first line\n\n_third line_"
      result `shouldEqual` "[first line]\n\n[_third line_]"
