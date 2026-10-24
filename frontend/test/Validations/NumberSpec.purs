module Test.Validations.NumberSpec where

import Prelude

import Data.Either (either)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Exception (name, try)
import Test.Components.HtmlComponentsSpec (loadIndexHtmlIntoDom)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Validations.Number (valueAsNumber)
import Web.HTML.HTMLInputElement (HTMLInputElement)

foreign import createInputWithValue :: String -> Effect HTMLInputElement

spec :: Spec Unit
spec = do
  describe "valueAsNumber" do
    it "parses `1` successfully" $ liftEffect do
      loadIndexHtmlIntoDom
      input <- createInputWithValue "1"
      value <- valueAsNumber "testId" input
      value `shouldEqual` 1.0

    it "fails on `1a` with InvalidInput" $ liftEffect do
      loadIndexHtmlIntoDom
      input <- createInputWithValue "1a"
      result <- try (valueAsNumber "testId" input)
      (either (\err -> name err == "InvalidInput") (const false) result) `shouldEqual` true
