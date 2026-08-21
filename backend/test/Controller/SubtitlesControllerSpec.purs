module Test.Controller.SubtitlesControllerSpec where

import Prelude

import Controller.SubtitlesController (linesFromSegment)
import Data.Foldable (all)
import Data.String (length)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (Color(..), DurationRange(..), Font(..), Position(..), Subtitle(..))
import Model.State.SubtitleConstraints (maxSubtitleCharsPerLine)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "linesFromSegment" do
    it "splits word timestamps into lines under the shared max char limit" do
      let
        segment =
          { start: 0.0
          , end: 5.0
          , text: ""
          , words:
              [ { word: "parlo", start: 0.0, end: 0.5 }
              , { word: "di", start: 0.5, end: 0.8 }
              , { word: "musica", start: 0.8, end: 1.3 }
              , { word: "italiana", start: 1.3, end: 2.0 }
              , { word: "contemporanea", start: 2.0, end: 2.8 }
              , { word: "molto", start: 2.8, end: 3.1 }
              , { word: "bella", start: 3.1, end: 3.5 }
              ]
          }
        lines = linesFromSegment segment
      all
        ( \(Subtitle { value }) ->
            length value <= maxSubtitleCharsPerLine
        )
        lines
        `shouldEqual` true

    it "falls back to segment text when words are missing" do
      let
        segment =
          { start: 1.0
          , end: 2.0
          , text: " ciao "
          , words: []
          }
      linesFromSegment segment `shouldEqual`
        [ Subtitle
            { videoPosition: DurationRange { start: Milliseconds 1000.0, end: Milliseconds 2000.0 }
            , value: "ciao"
            , font: Impact
            , fontSize: 36
            , color: White
            , screenPosition: Bottom
            }
        ]

