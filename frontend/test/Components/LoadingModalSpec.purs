module Test.Components.LoadingModalSpec where

import Prelude

import Components.LoadingModal (loadingModalExtraContentValues, parseLoadingModalExtraContentLabel)
import Data.Array (all)
import Data.Maybe (isJust)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "parseLoadingModalExtraContentLabel" do
    it "parses every loading modal extra content label" do
      all (isJust <<< parseLoadingModalExtraContentLabel <<< _.label) loadingModalExtraContentValues
        `shouldEqual` true
