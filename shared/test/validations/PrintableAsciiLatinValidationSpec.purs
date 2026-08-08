module Test.Validations.PrintableAsciiLatinValidationSpec where

import Data.Foldable (traverse_)
import Data.Validation.Semigroup (isValid)
import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import Validations.PrintableAsciiLatinValidation (printableAsciiLatinValidation)

spec :: Spec Unit
spec = do
  describe "printableAsciiLatinValidation" do
    it "accepts letters only" $
      isValid (printableAsciiLatinValidation "id" "Hello") `shouldEqual` true

    it "accepts letters and numbers" $
      isValid (printableAsciiLatinValidation "id" "Artist1") `shouldEqual` true

    it "accepts letters and spaces" $
      isValid (printableAsciiLatinValidation "id" "John Doe") `shouldEqual` true

    it "accepts letters numbers and spaces" $
      isValid (printableAsciiLatinValidation "id" "Artist 42") `shouldEqual` true

    it "accepts Italian accented letters" $
      isValid (printableAsciiLatinValidation "id" "Alessandro Barbèro") `shouldEqual` true

    it "accepts uppercase Italian accents" $
      isValid (printableAsciiLatinValidation "id" "È un test") `shouldEqual` true

    it "accepts apostrophe" $
      isValid (printableAsciiLatinValidation "id" "testo con apostrofo '") `shouldEqual` true

    it "rejects empty string" $
      isValid (printableAsciiLatinValidation "id" "") `shouldEqual` false

    it "rejects not printable ASCII and outside latin" $
      traverse_ (\s -> isValid (printableAsciiLatinValidation "id" s) `shouldEqual` false)
        [ "hello\nworld"
        , "tab\tcharacter"
        , "\x00byte"
        , "\x1Fcontrol"
        , "del\x7Fchar"
        , "emoji🙂"
        , "中文字符"
        , "русский"
        , "हिन्दी"
        , "Ωmega"
        , "smart quotes “ ”"
        , "en dash –"
        , "euro €"
        , "Ārā"
        ]
