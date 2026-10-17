module Command.Ffmpeg.Transcription where

-- import Prelude

-- import Command.Command (runCommand)
-- import Command.Ffmpeg.Base (baseFlagsInput, baseFlagsOutput)
-- import Constants (mp4, gif, srt)
-- import Conversion.Time (millisecondsToSecondsString)
-- import Data.Array (mapWithIndex, null, singleton)
-- import Data.Foldable (fold)
-- import Data.Maybe (Maybe(..))
-- import Data.Time.Duration (Milliseconds(..))
-- import Effect (Effect)
import Effect.Aff (Aff)
-- import Effect.Class (liftEffect)
-- import Effect.Console (log)
-- import MinsiErrors (MinsiError(..))
import Model.State.State (State)
-- import Node.Buffer (fromString)
-- import Node.Encoding (Encoding(..))
-- import Node.FS.Sync (rm, writeFile)
import Node.Library.Execa (ExecaResult)
-- import Node.Path (FilePath)

import Partial.Unsafe (unsafeCrashWith)

makeTranscription :: State -> Aff (Array ExecaResult)
makeTranscription state = unsafeCrashWith "TODO: implement makeTranscription"
