module Model.ProcessStatus where

import Data.Maybe (Maybe(..))
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
      _ ->
        case stripPrefix (Pattern "Failed: ") s of
          Just err -> pure (Failed err)
          Nothing ->
            if s == "Failed" then
              pure (Failed "")
            else
              fail $ TypeMismatch "ProcessStatus" $ "Invalid ProcessStatus: " <> s
