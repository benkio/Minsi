module Test.Components.HtmlComponentsSpec where

import Prelude

import Components.HtmlComponents (loadComponents)
import Effect (Effect)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)

foreign import loadIndexHtmlIntoDom :: Effect Unit

spec :: Spec Unit
spec = do
  describe "loadComponents" do
    it "returns without crashing against public/index.html" $ liftEffect do
      loadIndexHtmlIntoDom
      void loadComponents
