module Model.ProcessStatus where

import Prelude

data ProcessStatus
  = Pending
  | Succeed
  | Failed

instance Show ProcessStatus where
  show Pending = "Pending"
  show Succeed = "Succeed"
  show Failed = "Failed"
