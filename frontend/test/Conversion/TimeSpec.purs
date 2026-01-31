module Test.Conversion.TimeSpec where

import Conversion.Time (formatToThreeDecimals)
import Data.Either (Either(..))
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect.Class (liftEffect)
import Prelude
import Test.Arbitrary (DecimalNumber(..))
import Test.QuickCheck (quickCheck)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail)

spec :: Spec Unit
spec = do
  describe "formatToThreeDecimals" do
    it "formats as xxx.yyy" $ liftEffect do
      case regex "^[0-9]+\\.[0-9]{3}$" noFlags of
        Left err -> fail $ "Failed to compile test regex. Error: " <> show err
        Right r ->
          quickCheck \(DecimalNumber n) ->
            test r (formatToThreeDecimals n)
