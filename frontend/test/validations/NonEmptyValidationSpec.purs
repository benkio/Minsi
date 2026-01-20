module Test.Validations.NonEmptyValidationSpec where

import Prelude
import Effect.Class (liftEffect)
import Test.Arbitrary (NonEmptyASCIIString(..), EmptyASCIIString(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Data.Validation.Semigroup (isValid, toEither)
import Data.Either (Either(Left, Right))
import Data.String.Regex (test)
import Validations.NonEmptyValidation (nonEmptyRegexValidation, nonEmptyValidation)

spec :: Spec Unit
spec = do
  describe "nonEmptyRegex" do
    it "should be a valid regex pattern string" $ liftEffect $ do
      let regexResult = nonEmptyRegexValidation
      isValid regexResult `shouldEqual` true

  describe "nonEmptyRegexValidation" do
    it "should create a valid regex that matches non-empty strings" $ liftEffect $ do
      let regexResult = nonEmptyRegexValidation
      isValid regexResult `shouldEqual` true
      case toEither regexResult of
        Right regex -> do
          test regex "hello" `shouldEqual` true
          test regex "  hello  " `shouldEqual` true
          test regex "" `shouldEqual` false
          test regex "   " `shouldEqual` false
        Left _ -> pure unit

  describe "nonEmptyValidation" do
    it "should validate a non-empty string" $ liftEffect $
      quickCheck
        ( \(NonEmptyASCIIString s) ->
            (isValid <<< nonEmptyValidation) s
        )
    it "should not validate a empty string" $ liftEffect $
      quickCheck
        ( \(EmptyASCIIString s) ->
            (not <<< isValid <<< nonEmptyValidation) s
        )
