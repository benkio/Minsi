module Test.Components.HTMLTitleSpec where

import Prelude

import Components.HTMLTitle (calculateNextElement, normalTitle, wipTitlePrefix)
import Data.Array (head, index, last, length, mapWithIndex)
import Data.Foldable (for_)
import Data.Maybe (maybe)
import Data.Tuple (Tuple(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
  describe "calculateNextElement" do
    it "starts from the first prefix when the title has none" do
      calculateNextElement normalTitle `shouldEqual` (maybe "" identity (head wipTitlePrefix))
    it "starts from the first prefix on an empty title" do
      calculateNextElement "" `shouldEqual` (maybe "" identity (head wipTitlePrefix))
    it "advances to the next prefix" do
      for_ (mapWithIndex Tuple wipTitlePrefix) \(Tuple i prefix) ->
        when (i < length wipTitlePrefix - 1) $
          calculateNextElement (prefix <> " " <> normalTitle)
            `shouldEqual` (maybe "" identity (index wipTitlePrefix (i + 1)))
    it "wraps around after the last prefix" do
      let lastPrefix = maybe "" identity (last wipTitlePrefix)
      calculateNextElement (lastPrefix <> " " <> normalTitle)
        `shouldEqual` (maybe "" identity (head wipTitlePrefix))
