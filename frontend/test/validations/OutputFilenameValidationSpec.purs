module Test.Validations.OutputFilenameValidationSpec where

import Prelude

import Data.Validation.Semigroup (isValid)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Validations.OutputFilenameValidation (outputFilenameValidation)

spec :: Spec Unit
spec = do
  describe "outputFilenameValidation" do
    it "accepts valid prefix_Name format" $
      isValid (outputFilenameValidation "id" "rphjb_Hello") `shouldEqual` true

    it "accepts single letter prefix" $
      isValid (outputFilenameValidation "id" "a_Test") `shouldEqual` true

    it "accepts 5 letter prefix" $
      isValid (outputFilenameValidation "id" "abcde_Video") `shouldEqual` true

    it "accepts prefix with numbers in name part" $
      isValid (outputFilenameValidation "id" "xah_File123") `shouldEqual` true

    it "rejects prefix longer than 5 characters" $
      isValid (outputFilenameValidation "id" "abcdef_Hello") `shouldEqual` false

    it "rejects uppercase in prefix" $
      isValid (outputFilenameValidation "id" "Abc_Hello") `shouldEqual` false

    it "rejects numbers in prefix" $
      isValid (outputFilenameValidation "id" "ab1_Hello") `shouldEqual` false

    it "rejects missing underscore separator" $
      isValid (outputFilenameValidation "id" "abcHello") `shouldEqual` false

    it "rejects lowercase first letter after underscore" $
      isValid (outputFilenameValidation "id" "abc_hello") `shouldEqual` false

    it "rejects spaces in name" $
      isValid (outputFilenameValidation "id" "abc_Hello World") `shouldEqual` false

    it "rejects empty string" $
      isValid (outputFilenameValidation "id" "") `shouldEqual` false

    it "rejects prefix only with underscore" $
      isValid (outputFilenameValidation "id" "abc_") `shouldEqual` false

    it "rejects underscore only" $
      isValid (outputFilenameValidation "id" "_") `shouldEqual` false
