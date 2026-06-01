module Test.Command.GifSpec where

import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Prelude
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (Subtitle(..), DurationRange(..), Font(..), Color(..), Position(..))
import Command.Ffmpeg.Gif (makeSrtString)

spec :: Spec Unit
spec = do
  describe "makeSrtString" do
    it "should return the expected srt string for a subtitle" do
      let
        inputSubtitle =
          Subtitle
            { videoPosition: DurationRange { start: Milliseconds 0.0, end: Milliseconds 5000.0 }
            , value: "Hello world"
            , font: Impact
            , fontSize: 24
            , color: White
            , screenPosition: Top
            }
      makeSrtString 1 inputSubtitle `shouldEqual`
        "1\n00:00:00,000 --> 00:00:05,000\n{\\an8}<font face=\"Impact\" size=\"24px\" color=\"#ffffff\">Hello world</font>\n\n"
