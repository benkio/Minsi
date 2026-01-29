module Model.ProcessStatus where

import Prelude

data ProcessStatus
  = Pending
  | Succeed
  | Failed

derive instance Eq ProcessStatus

instance Show ProcessStatus where
  show Pending = "Pending"
  show Succeed = "Succeed"
  show Failed = "Failed"

--TODO: test this
isFinished :: ProcessStatus -> Boolean
isFinished Pending = false
isFinished _ = true
