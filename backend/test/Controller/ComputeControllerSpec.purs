module Test.Controller.ComputeControllerSpec where

import Prelude

import Controller.ComputeController (cutDownloadRequired, shiftVideoSyncChanged, videoNormalizationRequired, whisperRegenerationRequired)
import Data.Maybe (Maybe(..), fromJust)
import Data.Newtype (unwrap)
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
  , shiftVideoSync: Milliseconds 0.0
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

  describe "shiftVideoSyncChanged" do
    it "returns false when there is no old state" $
      shiftVideoSyncChanged Nothing (mkState source1 cut1) `shouldEqual` false

    it "returns false when shiftVideoSync is unchanged" $
      shiftVideoSyncChanged (Just (mkState source1 cut1)) (mkState source1 cut1) `shouldEqual` false

    it "returns true when shiftVideoSync changes" $
      shiftVideoSyncChanged
        (Just (mkState source1 cut1))
        (State $ (unwrap $ mkState source1 cut1) { shiftVideoSync = Milliseconds 500.0 })
        `shouldEqual` true

  describe "videoNormalizationRequired" do
    it "returns true when shiftVideoSync changes but source and cut range do not" $
      videoNormalizationRequired
        (Just (mkState source1 cut1))
        (State $ (unwrap $ mkState source1 cut1) { shiftVideoSync = Milliseconds 500.0 })
        `shouldEqual` true

  describe "whisperRegenerationRequired" do
    it "returns true when MP3 is missing and whisper json is missing" $
      whisperRegenerationRequired false false `shouldEqual` true

    it "returns true when MP3 is missing and whisper json exists" $
      whisperRegenerationRequired false true `shouldEqual` true

    it "returns true when MP3 exists but whisper json is missing" $
      whisperRegenerationRequired true false `shouldEqual` true

    it "returns false when both MP3 and whisper json exist" $
      whisperRegenerationRequired true true `shouldEqual` false
