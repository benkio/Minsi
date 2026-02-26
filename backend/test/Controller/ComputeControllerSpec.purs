module Test.Controller.ComputeControllerSpec where

import Prelude

import Controller.ComputeController (cutDownloadRequired)
import Data.Maybe (Maybe(..), fromJust)
import Data.Time.Duration (Milliseconds(..))
import Model.State (DurationRange(..), State(..), WURL(..))
import Partial.Unsafe (unsafePartial)
import Data.URL (fromString)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

mkWURL :: String -> WURL
mkWURL s = WURL (unsafePartial fromJust $ fromString s)

mkState :: WURL -> DurationRange -> State
mkState url cutVideo = State
  { youtubeUrl: url
  , cutVideo
  , filename: "test.mp4"
  , reverseLoop: false
  , artist: "artist"
  , title: "title"
  , subtitles: []
  }

url1 :: WURL
url1 = mkWURL "https://www.youtube.com/watch?v=abc123"

url2 :: WURL
url2 = mkWURL "https://www.youtube.com/watch?v=def456"

cut1 :: DurationRange
cut1 = DurationRange { start: Milliseconds 0.0, end: Milliseconds 1000.0 }

cut2 :: DurationRange
cut2 = DurationRange { start: Milliseconds 500.0, end: Milliseconds 2000.0 }

spec :: Spec Unit
spec = do
  describe "cutDownloadRequired" do
    it "returns true when there is no old state" $
      cutDownloadRequired Nothing (mkState url1 cut1) `shouldEqual` true

    it "returns false when URL and cut range are the same" $
      cutDownloadRequired (Just (mkState url1 cut1)) (mkState url1 cut1) `shouldEqual` false

    it "returns true when only the URL changes" $
      cutDownloadRequired (Just (mkState url1 cut1)) (mkState url2 cut1) `shouldEqual` true

    it "returns true when only the cut range changes" $
      cutDownloadRequired (Just (mkState url1 cut1)) (mkState url1 cut2) `shouldEqual` true

    it "returns true when both URL and cut range change" $
      cutDownloadRequired (Just (mkState url1 cut1)) (mkState url2 cut2) `shouldEqual` true
