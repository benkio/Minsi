module Test.Validations.YoutubeValidationSpec where

import Prelude
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Data.Validation.Semigroup (isValid, toEither)
import Data.Either (Either(Left, Right))
import Data.String.Regex (test)
import Validations.YoutubeValidation (youtubeRegex, youtubeRegexValidation, youtubeUrlValidation)

spec :: Spec Unit
spec = do
  describe "youtubeRegex" do
    it "should be a valid regex pattern string" $ liftEffect $ do
      let regexResult = youtubeRegexValidation
      isValid regexResult `shouldEqual` true

  describe "youtubeRegexValidation" do
    it "should create a valid regex that matches youtube URLs" $ liftEffect $ do
      let regexResult = youtubeRegexValidation
      isValid regexResult `shouldEqual` true
      case toEither regexResult of
        Right regex -> do
          test regex "https://www.youtube.com/watch?v=dQw4w9WgXcQ" `shouldEqual` true
          test regex "https://youtu.be/dQw4w9WgXcQ" `shouldEqual` true
          test regex "not a youtube url" `shouldEqual` false
        Left _ -> pure unit

  describe "youtubeUrlValidation" do
    it "should validate a standard youtube.com URL" $ liftEffect $ do
      result <- youtubeUrlValidation "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      isValid result `shouldEqual` true
    it "should validate a standard youtube.com URL with time query parameter" $ liftEffect $ do
      result <- youtubeUrlValidation "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s"
      isValid result `shouldEqual` true
    it "should validate a youtu.be short URL" $ liftEffect $ do
      result <- youtubeUrlValidation "https://youtu.be/dQw4w9WgXcQ"
      isValid result `shouldEqual` true
    it "should validate a youtube.com URL without www" $ liftEffect $ do
      result <- youtubeUrlValidation "https://youtube.com/watch?v=dQw4w9WgXcQ"
      isValid result `shouldEqual` true
    it "should validate a youtube.com URL without https" $ liftEffect $ do
      result <- youtubeUrlValidation "http://www.youtube.com/watch?v=dQw4w9WgXcQ"
      isValid result `shouldEqual` true
    it "should reject an invalid URL" $ liftEffect $ do
      result <- youtubeUrlValidation "not a youtube url"
      isValid result `shouldEqual` false
