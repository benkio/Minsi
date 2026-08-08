module Test.Validations.MaxCharactersValidationSpec where

import Prelude

import Data.Either (Either(..))
import Data.Map as Map
import Data.Validation.Semigroup (isValid, toEither)
import Model.ValidationErrors (toMap)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Validations.MaxCharatersValidation (maxCharsValidation)

spec :: Spec Unit
spec = do
  describe "maxCharsValidation" do
    it "accepts strings shorter than max length" do
      isValid (maxCharsValidation 5 "id" "hey") `shouldEqual` true

    it "accepts strings equal to max length" do
      isValid (maxCharsValidation 5 "id" "hello") `shouldEqual` true

    it "rejects strings longer than max length" do
      let res = maxCharsValidation 5 "id" "helloo"
      isValid res `shouldEqual` false
      case toEither res of
        Left errs ->
          toMap errs `shouldEqual`
            Map.singleton "id" "Invalid Input, max number of char exceded, got: 6 - max: 5"
        Right _ -> fail "Expected invalid result for too-long input, but got valid"
