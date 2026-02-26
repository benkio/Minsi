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
  | LocalFileUploaded

derive instance Eq ProcessStatus

instance Show ProcessStatus where
  show Pending = "Pending"
  show Succeed = "Succeed"
  show LocalFileUploaded = "LocalFileUploaded"
  show (Failed e) = "Failed: " <> e

instance ReadForeign ProcessStatus where
  readImpl f = do
    s <- readImpl f
    case s of
      "Pending" -> pure Pending
      "Succeed" -> pure Succeed
      "LocalFileUploaded" -> pure LocalFileUploaded
      "Failed" -> pure (Failed "")
      x -> fail $ TypeMismatch "ProcessStatus" $ "Invalid ProcessStatus: " <> x
