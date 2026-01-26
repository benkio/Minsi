module Command.Command where

import Effect.Class (liftEffect)
import Data.Time.Duration (Milliseconds(..))
import Control.Monad.Error.Class (catchError)
import Data.Foldable (intercalate)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Console (log)
import Effect.Exception (message)
import MinsiError (MinsiError, throwMinsiError)
import Node.ChildProcess.Types (stringSignal)
import Node.Library.Execa (ExecaProcess, execa)
import Node.Library.Execa.Which (isWindows)
import Prelude

runCommand :: Array String -> (String -> MinsiError) -> String -> Aff ExecaProcess
runCommand args errorConstructor commandExecutable =
    catchError
    ( do
        liftEffect $ log ("Execute Command: " <> commandExecutable <> " " <> show (intercalate " " args))
        win <- liftEffect isWindows
        let shell = if win then "cmd.exe" else "/bin/sh"
        execa commandExecutable args (\options -> options {shell = Just shell, timeout = Just {killSignal: stringSignal "SIGTERM", milliseconds: Milliseconds 300000.0}})
    )
    ( \e -> liftEffect $ throwMinsiError (errorConstructor (message e))
    )
