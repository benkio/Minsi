module Test.StateSpec where

import Prelude

import Model.State.StateFromHtml (youtubeUrlValidation, cutVideoValidation)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldSatisfy, shouldEqual)
import Data.Validation.Semigroup (V)
import Data.Validation.Semigroup as V
import Data.Either (Either(..))

isValid :: forall e a. V e a -> Boolean
isValid v = case V.toEither v of
  Right _ -> true
  Left _ -> false

isInvalid :: forall e a. V e a -> Boolean
isInvalid v = case V.toEither v of
  Left _ -> true
  Right _ -> false

spec :: Spec Unit
spec = do
  describe "youtubeUrlValidation" do
    it "should validate a standard youtube.com URL" $ liftEffect $ do
      result <- youtubeUrlValidation "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      result `shouldSatisfy` isValid
    it "should validate a standard youtube.com URL with time query parameter" $ liftEffect $ do
      result <- youtubeUrlValidation "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s"
      result `shouldSatisfy` isValid
    it "should validate a youtu.be short URL" $ liftEffect $ do
      result <- youtubeUrlValidation "https://youtu.be/dQw4w9WgXcQ"
      result `shouldSatisfy` isValid
    it "should validate a youtube.com URL without www" $ liftEffect $ do
      result <- youtubeUrlValidation "https://youtube.com/watch?v=dQw4w9WgXcQ"
      result `shouldSatisfy` isValid
    it "should validate a youtube.com URL without https" $ liftEffect $ do
      result <- youtubeUrlValidation "http://www.youtube.com/watch?v=dQw4w9WgXcQ"
      result `shouldSatisfy` isValid
    it "should reject an invalid URL" $ liftEffect $ do
      result <- youtubeUrlValidation "not a youtube url"
      result `shouldSatisfy` isInvalid
  describe "cutVideoValidation" do
    it "should validate when start is less than end" do
      let result = cutVideoValidation 0.0 100.0
      isValid result `shouldEqual` true
    it "should validate when start equals end" do
      let result = cutVideoValidation 50.0 50.0
      isValid result `shouldEqual` true
    it "should validate when start is zero and end is positive" do
      let result = cutVideoValidation 0.0 10.5
      isValid result `shouldEqual` true
    it "should reject when start is greater than end" do
      let result = cutVideoValidation 100.0 50.0
      isInvalid result `shouldEqual` true
    it "should reject when start is positive and end is zero" do
      let result = cutVideoValidation 10.0 0.0
      isInvalid result `shouldEqual` true
