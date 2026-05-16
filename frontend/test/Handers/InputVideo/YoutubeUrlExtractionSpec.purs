module Test.Handers.InputVideo.YoutubeUrlExtractionSpec where

import Data.Maybe (Maybe(..), fromJust)
import Data.URL (Path(..), URL, fromString)
import Effect.Class (liftEffect)
import Handlers.InputVideo.YoutubeUrlExtraction
  ( extractYoutubeVideoId
  , extractYoutubeVideoStartTime
  , parseUnit
  , parseYouTubeT
  , pathToArray
  )
import Partial.Unsafe (unsafePartial)
import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

-- Helper to create URL from string (unsafe but fine for tests)
urlFromString :: String -> URL
urlFromString = unsafePartial fromJust <<< fromString

spec :: Spec Unit
spec = do
  describe "extractYoutubeVideoId" do
    it "should extract video ID from standard youtube.com URL with v parameter" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      extractYoutubeVideoId url `shouldEqual` Just "dQw4w9WgXcQ"

    it "should extract video ID from youtube.com URL with v parameter and other query params" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s&list=PLxxx"
      extractYoutubeVideoId url `shouldEqual` Just "dQw4w9WgXcQ"

    it "should extract video ID from youtu.be short URL" $ liftEffect $ do
      let url = urlFromString "https://youtu.be/dQw4w9WgXcQ"
      extractYoutubeVideoId url `shouldEqual` Just "dQw4w9WgXcQ"

    it "should extract video ID from youtu.be URL with query parameters" $ liftEffect $ do
      let url = urlFromString "https://youtu.be/dQw4w9WgXcQ?t=364"
      extractYoutubeVideoId url `shouldEqual` Just "dQw4w9WgXcQ"

    it "should extract video ID from youtube.com URL without www" $ liftEffect $ do
      let url = urlFromString "https://youtube.com/watch?v=PHi-UNsm2Ds"
      extractYoutubeVideoId url `shouldEqual` Just "PHi-UNsm2Ds"
    it "should extract video ID from youtube.com URL shorts" $ liftEffect $ do
      let
        url1 = urlFromString "https://youtube.com/shorts/_JryLY7pXLQ"
        url2 = urlFromString "https://www.youtube.com/shorts/C8p4SOnSXeQ"
      extractYoutubeVideoId url1 `shouldEqual` Just "_JryLY7pXLQ"
      extractYoutubeVideoId url2 `shouldEqual` Just "C8p4SOnSXeQ"

    it "should return Nothing for URL without video ID" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/"
      extractYoutubeVideoId url `shouldEqual` Nothing

  describe "pathToArray" do
    it "should convert PathEmpty to empty array" $ liftEffect $ do
      pathToArray PathEmpty `shouldEqual` []

    it "should convert PathAbsolute to array" $ liftEffect $ do
      pathToArray (PathAbsolute [ "mp4", "dQw4w9WgXcQ" ]) `shouldEqual` [ "mp4", "dQw4w9WgXcQ" ]

    it "should convert PathRelative to array" $ liftEffect $ do
      pathToArray (PathRelative [ "watch" ]) `shouldEqual` [ "watch" ]

    it "should handle single element path" $ liftEffect $ do
      pathToArray (PathAbsolute [ "dQw4w9WgXcQ" ]) `shouldEqual` [ "dQw4w9WgXcQ" ]

  describe "extractYoutubeVideoStartTime" do
    it "should extract start time from URL with t parameter in seconds" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=90"
      extractYoutubeVideoStartTime url `shouldEqual` 90

    it "should extract start time from URL with t parameter in seconds format" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s"
      extractYoutubeVideoStartTime url `shouldEqual` 10

    it "should extract start time from URL with t parameter in minutes format" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=5m"
      extractYoutubeVideoStartTime url `shouldEqual` 300

    it "should extract start time from URL with t parameter in hours format" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=1h"
      extractYoutubeVideoStartTime url `shouldEqual` 3600

    it "should extract start time from URL with combined time format" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=1h30m45s"
      extractYoutubeVideoStartTime url `shouldEqual` 5445

    it "should return 0 for URL without t parameter" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      extractYoutubeVideoStartTime url `shouldEqual` 0

    it "should return 0 for URL with empty t parameter" $ liftEffect $ do
      let url = urlFromString "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t="
      extractYoutubeVideoStartTime url `shouldEqual` 0

  describe "parseUnit" do
    it "should parse hours from string" $ liftEffect $ do
      parseUnit "1h30m45s" "h" `shouldEqual` 1
      parseUnit "2h" "h" `shouldEqual` 2
      parseUnit "10h20m" "h" `shouldEqual` 10

    it "should parse minutes from string" $ liftEffect $ do
      parseUnit "1h30m45s" "m" `shouldEqual` 30
      parseUnit "5m" "m" `shouldEqual` 5
      parseUnit "10m20s" "m" `shouldEqual` 10

    it "should parse seconds from string" $ liftEffect $ do
      parseUnit "1h30m45s" "s" `shouldEqual` 45
      parseUnit "90s" "s" `shouldEqual` 90
      parseUnit "10s" "s" `shouldEqual` 10

    it "should return 0 when unit not found" $ liftEffect $ do
      parseUnit "90" "h" `shouldEqual` 0
      parseUnit "hello" "m" `shouldEqual` 0

    it "should handle case sensitivity" $ liftEffect $ do
      parseUnit "1H30M45S" "h" `shouldEqual` 0
      parseUnit "1H30M45S" "m" `shouldEqual` 0
      parseUnit "1H30M45S" "s" `shouldEqual` 0

  describe "parseYouTubeT" do
    it "should parse plain seconds format" $ liftEffect $ do
      parseYouTubeT "90" `shouldEqual` Just 90
      parseYouTubeT "0" `shouldEqual` Just 0
      parseYouTubeT "3600" `shouldEqual` Just 3600

    it "should parse seconds with s suffix" $ liftEffect $ do
      parseYouTubeT "90s" `shouldEqual` Just 90
      parseYouTubeT "10s" `shouldEqual` Just 10

    it "should parse minutes with m suffix" $ liftEffect $ do
      parseYouTubeT "5m" `shouldEqual` Just 300
      parseYouTubeT "1m" `shouldEqual` Just 60

    it "should parse hours with h suffix" $ liftEffect $ do
      parseYouTubeT "1h" `shouldEqual` Just 3600
      parseYouTubeT "2h" `shouldEqual` Just 7200

    it "should parse combined format" $ liftEffect $ do
      parseYouTubeT "1h30m45s" `shouldEqual` Just 5445
      parseYouTubeT "2h15m30s" `shouldEqual` Just 8130
      parseYouTubeT "1h5m10s" `shouldEqual` Just 3910

    it "should parse format with only hours and minutes" $ liftEffect $ do
      parseYouTubeT "1h30m" `shouldEqual` Just 5400
      parseYouTubeT "2h15m" `shouldEqual` Just 8100

    it "should parse format with only hours and seconds" $ liftEffect $ do
      parseYouTubeT "1h45s" `shouldEqual` Just 3645
      parseYouTubeT "2h30s" `shouldEqual` Just 7230

    it "should parse format with only minutes and seconds" $ liftEffect $ do
      parseYouTubeT "30m45s" `shouldEqual` Just 1845
      parseYouTubeT "5m10s" `shouldEqual` Just 310

    it "should handle case insensitive input" $ liftEffect $ do
      parseYouTubeT "1H30M45S" `shouldEqual` Just 5445
      parseYouTubeT "90S" `shouldEqual` Just 90
      parseYouTubeT "5M" `shouldEqual` Just 300

    it "should return Nothing for invalid input" $ liftEffect $ do
      parseYouTubeT "invalid" `shouldEqual` Nothing
      parseYouTubeT "abc" `shouldEqual` Nothing
      parseYouTubeT "xyz123" `shouldEqual` Nothing

    it "should return Nothing for empty string" $ liftEffect $ do
      parseYouTubeT "" `shouldEqual` Nothing
