module Test.Controller.ComputeControllerSpec where

import Prelude

import Controller.ComputeController (cutDownloadRequired)
import Data.Maybe (Maybe(..), fromJust)
import Data.Time.Duration (Milliseconds(..))
import Model.State.State (DurationRange(..), Source(..), State(..), WURL(..))
import Partial.Unsafe (unsafePartial)
import Data.URL (fromString)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

mkWURL :: String -> WURL
mkWURL s = WURL (unsafePartial fromJust $ fromString s)

mkState :: Source -> DurationRange -> State
mkState source cutVideo = State
  { source
  , cutVideo
  , filename: "test.mp4"
  , reverseLoop: false
  , uploadLocalFile: false
  , artist: "artist"
  , title: "title"
  , subtitles: []
  , syncAV: Milliseconds 0.0
  }

source1 :: Source
source1 = WebURL (mkWURL "https://www.youtube.com/watch?v=abc123")

source2 :: Source
source2 = WebURL (mkWURL "https://www.youtube.com/watch?v=def456")

cut1 :: DurationRange
cut1 = DurationRange { start: Milliseconds 0.0, end: Milliseconds 1000.0 }

cut2 :: DurationRange
cut2 = DurationRange { start: Milliseconds 500.0, end: Milliseconds 2000.0 }

spec :: Spec Unit
spec = do
  describe "cutDownloadRequired" do
    it "returns true when there is no old state" $
      cutDownloadRequired Nothing (mkState source1 cut1) `shouldEqual` true

    it "returns false when source and cut range are the same" $
      cutDownloadRequired (Just (mkState source1 cut1)) (mkState source1 cut1) `shouldEqual` false

    it "returns true when only the source changes" $
      cutDownloadRequired (Just (mkState source1 cut1)) (mkState source2 cut1) `shouldEqual` true

    it "returns true when only the cut range changes" $
      cutDownloadRequired (Just (mkState source1 cut1)) (mkState source1 cut2) `shouldEqual` true

    it "returns true when both source and cut range change" $
      cutDownloadRequired (Just (mkState source1 cut1)) (mkState source2 cut2) `shouldEqual` true
