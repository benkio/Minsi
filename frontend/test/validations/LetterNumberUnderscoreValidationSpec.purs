module Test.Validations.LetterNumberUnderscoreValidationSpec where

import Prelude

import Data.Validation.Semigroup (isValid)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Validations.LetterNumberUnderscoreValidation (letterNumberUnderscoreValidation)

spec :: Spec Unit
spec = do
  describe "letterNumberUnderscoreValidation" do
    it "accepts letters only" $
      isValid (letterNumberUnderscoreValidation "id" "Hello") `shouldEqual` true

    it "accepts letters and numbers" $
      isValid (letterNumberUnderscoreValidation "id" "file123") `shouldEqual` true

    it "accepts underscores" $
      isValid (letterNumberUnderscoreValidation "id" "my_file_1") `shouldEqual` true

    it "rejects spaces" $
      isValid (letterNumberUnderscoreValidation "id" "hello world") `shouldEqual` false

    it "rejects special characters" $
      isValid (letterNumberUnderscoreValidation "id" "file@name") `shouldEqual` false

    it "rejects empty string" $
      isValid (letterNumberUnderscoreValidation "id" "") `shouldEqual` false
