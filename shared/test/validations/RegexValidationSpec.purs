module Test.Validations.RegexValidationSpec where

import Prelude
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Data.Validation.Semigroup (isValid, toEither)
import Data.Either (either)
import Data.String.Regex (regex)
import Data.String.Regex.Flags (noFlags)
import Validations.RegexValidation (matches)

spec :: Spec Unit
spec = do
  describe "matches" do
    it "should return valid when string matches regex" $ liftEffect $ do
      either (const (pure unit))
        ( \regex -> do
            let result = matches regex "testId" "hello"
            isValid result `shouldEqual` true
            either (const $ pure unit) (\str -> str `shouldEqual` "hello") (toEither result)
        )
        (regex "hello" noFlags)

    it "should return invalid when string does not match regex" $ liftEffect $ do
      either (const (pure unit))
        ( \regex -> do
            let result = matches regex "testId" "world"
            isValid result `shouldEqual` false
        )
        (regex "hello" noFlags)

    it "should work with complex regex patterns" $ liftEffect $ do
      either (const (pure unit))
        ( \regex -> do
            let validResult = matches regex "testId" "hello"
            let invalidResult = matches regex "testId" "HELLO"
            isValid validResult `shouldEqual` true
            isValid invalidResult `shouldEqual` false
        )
        (regex "^[a-z]+$" noFlags)
