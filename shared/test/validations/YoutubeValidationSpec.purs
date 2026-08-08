module Test.Validations.YoutubeValidationSpec where

import Data.Either (either)
import Data.Traversable (traverse_)
import Data.Validation.Semigroup (isValid, toEither)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Validations.YoutubeValidation (youtubeRegexValidation, youtubeUrlValidation)
import Prelude

import Data.String.Regex (test)

spec :: Spec Unit
spec = do
  describe "youtubeRegex" do
    it "should be a valid regex pattern string" $ liftEffect $ do
      let regexResult = youtubeRegexValidation "testId"
      isValid regexResult `shouldEqual` true

  describe "youtubeRegexValidation" do
    it "should create a valid regex that matches youtube URLs" $ liftEffect $ do
      let regexResult = youtubeRegexValidation "testId"
      isValid regexResult `shouldEqual` true
      either (const $ pure unit)
        ( \regex -> do
            test regex "https://www.youtube.com/watch?v=dQw4w9WgXcQ" `shouldEqual` true
            test regex "https://youtube.com/shorts/_JryLY7pXLQ" `shouldEqual` true
            test regex "https://www.youtube.com/shorts/C8p4SOnSXeQ?t=30" `shouldEqual` true
            test regex "https://www.youtube.com/live/XRN1BsAwMCc" `shouldEqual` true
            test regex "https://www.youtube.com/live/XRN1BsAwMCc?t=2695" `shouldEqual` true
            test regex "https://www.youtube.com/live/vyB7BnvGOE4?t=2130" `shouldEqual` true
            test regex "https://youtu.be/dQw4w9WgXcQ" `shouldEqual` true
            test regex "not a youtube url" `shouldEqual` false
        )
        (toEither regexResult)

  describe "youtubeUrlValidation" do
    it "should validate a standard youtube.com URL" $ liftEffect $ do
      let result = youtubeUrlValidation "testId" "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      isValid result `shouldEqual` true
    it "should validate a standard youtube.com URL with time query parameter" $ liftEffect $ do
      let result = youtubeUrlValidation "testId" "https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10s"
      isValid result `shouldEqual` true
    it "should validate a youtu.be short URL" $ liftEffect $ do
      let
        input =
          [ "https://youtu.be/PHi-UNsm2Ds"
          , "https://youtu.be/dQw4w9WgXcQ"
          , "https://youtu.be/PHi-UNsm2Ds?t=364"
          ]
      traverse_ (\i -> isValid (youtubeUrlValidation "testId" i) `shouldEqual` true) input
    it "should validate a youtube.com URL without www" $ liftEffect $ do
      let result = youtubeUrlValidation "testId" "https://youtube.com/watch?v=dQw4w9WgXcQ"
      isValid result `shouldEqual` true
    it "should validate a youtube.com URL without https" $ liftEffect $ do
      let result = youtubeUrlValidation "testId" "http://www.youtube.com/watch?v=dQw4w9WgXcQ"
      isValid result `shouldEqual` true
    it "should reject an invalid URL" $ liftEffect $ do
      isValid (youtubeUrlValidation "testId" "not a youtube url") `shouldEqual` false
    it "should reject an youtube URL without id" $ liftEffect $ do
      isValid (youtubeUrlValidation "testId" "http://www.youtube.com/") `shouldEqual` false
      isValid (youtubeUrlValidation "testId" "https://www.youtube.com/") `shouldEqual` false
      isValid (youtubeUrlValidation "testId" "http://www.youtube.com") `shouldEqual` false
      isValid (youtubeUrlValidation "testId" "https://www.youtube.com") `shouldEqual` false
    it "should validate a youtube.com shorts URL" $ liftEffect $ do
      isValid (youtubeUrlValidation "testId" "https://youtube.com/shorts/_JryLY7pXLQ") `shouldEqual` true
      isValid (youtubeUrlValidation "testId" "https://www.youtube.com/shorts/C8p4SOnSXeQ") `shouldEqual` true
      isValid (youtubeUrlValidation "testId" "https://www.youtube.com/shorts/C8p4SOnSXeQ?t=30") `shouldEqual` true
    it "should validate a youtube.com live URL" $ liftEffect $ do
      isValid (youtubeUrlValidation "testId" "https://www.youtube.com/live/XRN1BsAwMCc") `shouldEqual` true
      isValid (youtubeUrlValidation "testId" "https://youtube.com/live/XRN1BsAwMCc") `shouldEqual` true
      isValid (youtubeUrlValidation "testId" "https://www.youtube.com/live/XRN1BsAwMCc?t=2695") `shouldEqual` true
      isValid (youtubeUrlValidation "testId" "https://www.youtube.com/live/vyB7BnvGOE4?t=2130") `shouldEqual` true
    it "should validate known Invidious and alternative watch instances" $ liftEffect $ do
      let
        videoId = "dQw4w9WgXcQ"

        youtubeInstances =
          [ "https://inv.nadeko.net/watch?v="
          , "https://yewtu.be/watch?v="
          , "https://invidious.nerdvpn.de/watch?v="
          , "https://yt.chocolatemoo53.com/watch?v="
          , "https://invidious.tiekoetter.com//watch?v="
          , "https://invidious.f5.si/watch?v="
          , "https://inv.zoomerville.com/watch?v="
          , "https://ymusicapp.com/watch?v="
          , "https://piped.video/watch?v="
          ]

        youtubeUrls = map (_ <> videoId) youtubeInstances
      traverse_ (\i -> isValid (youtubeUrlValidation "testId" i) `shouldEqual` true) youtubeUrls
