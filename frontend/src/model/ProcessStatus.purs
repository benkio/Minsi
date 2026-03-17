module Model.ProcessStatus where

import Prelude

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
  show (Failed _) = "Failed"
