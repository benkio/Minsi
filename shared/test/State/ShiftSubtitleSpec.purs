module Test.State.ShiftSubtitleSpec where

import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (DurationRange(..), Subtitle(..), Font(..), Color(..), Position(..), shiftSubtitle)

spec :: Spec Unit
spec = do
  describe "shiftSubtitle" do
    it "should shift subtitle duration range by the offset and preserve subtitle fields" $ do
      let
        original =
          Subtitle
            { videoPosition: DurationRange { start: Milliseconds 10.0, end: Milliseconds 20.0 }
            , value: "Test subtitle"
            , font: Impact
            , fontSize: 24
            , color: White
            , screenPosition: Top
            }
        shifted = shiftSubtitle (Milliseconds 5.0) original
      shifted `shouldEqual`
        Subtitle
          { videoPosition: DurationRange { start: Milliseconds 15.0, end: Milliseconds 25.0 }
          , value: "Test subtitle"
          , font: Impact
          , fontSize: 24
          , color: White
          , screenPosition: Top
          }
      original `shouldEqual`
        Subtitle
          { videoPosition: DurationRange { start: Milliseconds 10.0, end: Milliseconds 20.0 }
          , value: "Test subtitle"
          , font: Impact
          , fontSize: 24
          , color: White
          , screenPosition: Top
          }
