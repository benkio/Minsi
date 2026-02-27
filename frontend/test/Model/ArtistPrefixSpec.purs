module Test.Model.ArtistPrefixSpec where

import Prelude

import Data.Maybe (Maybe(..), isNothing)
import Model.ArtistPrefix (findMatchingPrefix, prefixForArtist)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "prefixForArtist" do
    it "returns the prefix for a known artist" $
      prefixForArtist "Xah Lee" `shouldEqual` Just "xah_"

    it "returns Nothing for an unknown artist" $
      isNothing (prefixForArtist "Unknown Artist") `shouldEqual` true

    it "trims whitespace before lookup" $
      prefixForArtist "  Xah Lee  " `shouldEqual` Just "xah_"

    it "returns prefix for Richard Philip Henry John Benson" $
      prefixForArtist "Richard Philip Henry John Benson" `shouldEqual` Just "rphjb_"

  describe "findMatchingPrefix" do
    it "finds a matching prefix at start of string" do
      let result = findMatchingPrefix "rphjb_SomeVideo"
      result `shouldEqual` Just { prefix: "rphjb_", rest: "SomeVideo" }

    it "returns Nothing when no prefix matches" $
      isNothing (findMatchingPrefix "unknownFile") `shouldEqual` true

    it "returns the matching prefix with empty rest" do
      let result = findMatchingPrefix "xah_"
      result `shouldEqual` Just { prefix: "xah_", rest: "" }

    it "finds ytai_ prefix" do
      let result = findMatchingPrefix "ytai_MyVideo"
      result `shouldEqual` Just { prefix: "ytai_", rest: "MyVideo" }
