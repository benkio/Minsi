module Test.State.SubtitlesToStringSpec where

import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State
  ( DurationRange(..)
  , Subtitle(..)
  , Font(..)
  , Color(..)
  , Position(..)
  , subtitlesToString
  )

mkSubtitle :: Number -> String -> Font -> Color -> Position -> Subtitle
mkSubtitle start value font color screenPosition =
  Subtitle
    { videoPosition: DurationRange { start: Milliseconds start, end: Milliseconds (start + 10.0) }
    , value
    , font
    , fontSize: 24
    , color
    , screenPosition
    }

spec :: Spec Unit
spec = do
  describe "subtitlesToString" do
    it "joins adjacent subtitles with the same font, color, and screen position on one line" $ do
      let
        subtitles =
          [ mkSubtitle 10.0 "Hello" Impact White Top
          , mkSubtitle 20.0 "world" Impact White Top
          ]
      subtitlesToString subtitles `shouldEqual` "Hello world"

    it "starts a new line when font, color, or screen position changes" $ do
      let
        subtitles =
          [ mkSubtitle 10.0 "First" Impact White Top
          , mkSubtitle 20.0 "line" Impact White Top
          , mkSubtitle 30.0 "Other" Impact Black Top
          , mkSubtitle 40.0 "Bottom" Impact Black Bottom
          , mkSubtitle 50.0 "Bold" ArialBlack Black Bottom
          ]
      subtitlesToString subtitles `shouldEqual` "First line\nOther\nBottom\nBold"

    it "sorts by video position before grouping" $ do
      let
        subtitles =
          [ mkSubtitle 30.0 "Third" Impact White Top
          , mkSubtitle 10.0 "First" Impact White Top
          , mkSubtitle 20.0 "Second" Impact White Top
          ]
      subtitlesToString subtitles `shouldEqual` "First second third"

    it "does not merge matching styles separated by a different group" $ do
      let
        subtitles =
          [ mkSubtitle 10.0 "One" Impact White Top
          , mkSubtitle 20.0 "Two" Impact Black Top
          , mkSubtitle 30.0 "Three" Impact White Top
          ]
      subtitlesToString subtitles `shouldEqual` "One\nTwo\nThree"

    it "lowercases and trims subtitle values" $ do
      let
        subtitles =
          [ mkSubtitle 10.0 "  HELLO  " Impact White Top
          , mkSubtitle 20.0 "  WORLD  " Impact White Top
          ]
      subtitlesToString subtitles `shouldEqual` "Hello world"
