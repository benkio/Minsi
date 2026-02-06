module Model.ProcessStatus where

import Data.Maybe (Maybe(..), maybe)
import Data.String.CodeUnits (stripPrefix)
import Data.String.Pattern (Pattern(..))
import Foreign (ForeignError(..), fail)
import Prelude
import Yoga.JSON (class ReadForeign, readImpl)

data ProcessStatus
  = Pending
  | Succeed
  | Failed String

derive instance Eq ProcessStatus

instance Show ProcessStatus where
  show Pending = "Pending"
  show Succeed = "Succeed"
  show (Failed e) = "Failed: " <> e

instance ReadForeign ProcessStatus where
  readImpl f = do
    s <- readImpl f
    case s of
      "Pending" -> pure Pending
      "Succeed" -> pure Succeed
      "Failed" -> pure (Failed "")
      x ->
        maybe
          (fail $ TypeMismatch "ProcessStatus" $ "Invalid ProcessStatus: " <> x)
          (pure <<< Failed)
          (stripPrefix (Pattern "Failed: ") x)
