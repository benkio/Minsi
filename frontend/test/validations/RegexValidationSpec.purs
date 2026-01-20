module Test.Validations.RegexValidationSpec where

import Prelude
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Data.Validation.Semigroup (isValid, toEither)
import Data.Either (Either(Left, Right), either)
import Data.String.Regex (regex)
import Data.String.Regex.Flags (noFlags)
import Validations.RegexValidation (matches)

spec :: Spec Unit
spec = do
  describe "matches" do
    it "should return valid when string matches regex" $ liftEffect $ do
      either (const (pure unit))
        ( \regex -> do
            let result = matches regex "hello"
            isValid result `shouldEqual` true
            case toEither result of
              Right str -> str `shouldEqual` "hello"
              Left _ -> pure unit
        )
        (regex "hello" noFlags)

    it "should return invalid when string does not match regex" $ liftEffect $ do
      either (const (pure unit))
        ( \regex -> do
            let result = matches regex "world"
            isValid result `shouldEqual` false
        )
        (regex "hello" noFlags)

    it "should work with complex regex patterns" $ liftEffect $ do
      either (const (pure unit))
        ( \regex -> do
            let validResult = matches regex "hello"
            let invalidResult = matches regex "HELLO"
            isValid validResult `shouldEqual` true
            isValid invalidResult `shouldEqual` false
        )
        (regex "^[a-z]+$" noFlags)
