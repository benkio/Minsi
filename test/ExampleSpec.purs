module Test.ExampleSpec where

import Prelude

import Test.Spec (Spec, describe, it, pending)
import Test.Spec.Assertions (shouldEqual)

spec :: Spec Unit
spec = do
    describe "purescript-spec" do
        describe "Attributes" do
            it "awesome" do
                let isAwesome = true
                isAwesome `shouldEqual` true
            pending "feature complete"
        describe "Features" do
            it "runs in NodeJS" $ pure unit
            it "runs in the browser" $ pure unit
            it "supports streaming reporters" $ pure unit
            it "is PureScript 0.15.x compatible" $ pure unit
