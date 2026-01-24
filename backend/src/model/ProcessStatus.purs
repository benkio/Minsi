module Model.ProcessStatus where

import Yoga.JSON (class WriteForeign, writeImpl)

data ProcessStatus
  = Pending
  | Succeed
  | Failed

instance WriteForeign ProcessStatus where
  writeImpl Pending = writeImpl "Pending"
  writeImpl Succeed = writeImpl "Succeed"
  writeImpl Failed = writeImpl "Failed"
