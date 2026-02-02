module Model.ProcessStatus where

import Prelude

data ProcessStatus
  = Pending
  | Succeed
  | Failed String

derive instance Eq ProcessStatus

instance Show ProcessStatus where
  show Pending = "Pending"
  show Succeed = "Succeed"
  show (Failed e) = "Failed: " <> e

isFinished :: ProcessStatus -> Boolean
isFinished Pending = false
isFinished _ = true
