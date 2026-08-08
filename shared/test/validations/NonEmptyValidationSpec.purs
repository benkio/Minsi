module Test.Validations.NonEmptyValidationSpec where

import Data.Either (Either(Left, Right))
import Data.String.Regex (test)
import Data.Validation.Semigroup (isValid, toEither)
import Effect.Class (liftEffect)
import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Validations.NonEmptyValidation (nonEmptyRegexValidation, nonEmptyValidation)

spec :: Spec Unit
spec = do
  describe "nonEmptyRegex" do
    it "should be a valid regex pattern string" $ liftEffect $ do
      let regexResult = nonEmptyRegexValidation "testId"
      isValid regexResult `shouldEqual` true

  describe "nonEmptyRegexValidation" do
    it "should create a valid regex that matches non-empty strings" $ liftEffect $ do
      let regexResult = nonEmptyRegexValidation "testId"
      isValid regexResult `shouldEqual` true
      case toEither regexResult of
        Right regex -> do
          test regex "hello" `shouldEqual` true
          test regex "  hello  " `shouldEqual` true
          test regex "" `shouldEqual` false
          test regex "   " `shouldEqual` false
        Left _ -> pure unit

  describe "nonEmptyValidation" do
    it "should validate non-empty strings" do
      isValid (nonEmptyValidation "testId" "hello") `shouldEqual` true
      isValid (nonEmptyValidation "testId" "  hello  ") `shouldEqual` true
      isValid (nonEmptyValidation "testId" "0") `shouldEqual` true
    it "should not validate empty-like strings" do
      isValid (nonEmptyValidation "testId" "") `shouldEqual` false
      isValid (nonEmptyValidation "testId" "   ") `shouldEqual` false
      isValid (nonEmptyValidation "testId" "\n\t") `shouldEqual` false
