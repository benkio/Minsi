module Model.ProcessStatus where

import Foreign (ForeignError(..), fail)
import Prelude
import Yoga.JSON (class ReadForeign, readImpl)

data ProcessStatus =
  Pending | Succeed | Failed

derive instance Eq ProcessStatus

instance Show ProcessStatus where
  show Pending = "Pending"
  show Succeed = "Succeed"
  show Failed = "Failed"

instance ReadForeign ProcessStatus where
  readImpl f = do
    s <- readImpl f
    case s of
      "Pending" -> pure Pending
      "Succeed" -> pure Succeed
      "Failed" -> pure Failed
      _ -> fail $ TypeMismatch "ProcessStatus" $ "Invalid ProcessStatus: " <> s
