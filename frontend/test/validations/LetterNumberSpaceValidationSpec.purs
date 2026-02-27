module Test.Validations.LetterNumberSpaceValidationSpec where

import Prelude

import Data.Validation.Semigroup (isValid)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Validations.LetterNumberSpaceValidation (letterNumberSpaceValidation)

spec :: Spec Unit
spec = do
  describe "letterNumberSpaceValidation" do
    it "accepts letters only" $
      isValid (letterNumberSpaceValidation "id" "Hello") `shouldEqual` true

    it "accepts letters and numbers" $
      isValid (letterNumberSpaceValidation "id" "Artist1") `shouldEqual` true

    it "accepts letters and spaces" $
      isValid (letterNumberSpaceValidation "id" "John Doe") `shouldEqual` true

    it "accepts letters numbers and spaces" $
      isValid (letterNumberSpaceValidation "id" "Artist 42") `shouldEqual` true

    it "accepts Italian accented letters" $
      isValid (letterNumberSpaceValidation "id" "Alessandro Barbèro") `shouldEqual` true

    it "accepts uppercase Italian accents" $
      isValid (letterNumberSpaceValidation "id" "È un test") `shouldEqual` true

    it "rejects underscores" $
      isValid (letterNumberSpaceValidation "id" "my_name") `shouldEqual` false

    it "rejects special characters" $
      isValid (letterNumberSpaceValidation "id" "name@here") `shouldEqual` false

    it "rejects empty string" $
      isValid (letterNumberSpaceValidation "id" "") `shouldEqual` false
