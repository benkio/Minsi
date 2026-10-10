module Domain.ProcessStatus where

import Prelude

data ProcessStatus
  = Pending String
  | Succeed
  | LocalFileUploaded String
  | Failed String

derive instance Eq ProcessStatus

instance Show ProcessStatus where
  show (Pending _) = "Pending"
  show Succeed = "Succeed"
  show (LocalFileUploaded _) = "LocalFileUploaded"
  show (Failed _) = "Failed"

isFinished :: ProcessStatus -> Boolean
isFinished (Pending _) = false
isFinished _ = true
