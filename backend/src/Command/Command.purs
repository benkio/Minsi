module Command.Command where

import Effect (Effect)

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
import Node.Library.Execa (ExecaProcess, execa, ExecaOptions, ExecaSyncOptions)
import Node.Library.Execa.Which (isWindows)
import Prelude

runCommand :: Array String -> (String -> MinsiError) -> String -> Aff ExecaProcess
runCommand args errorConstructor commandExecutable =
  catchError
    ( do
        liftEffect $ log ("Execute Command: " <> commandExecutable <> " " <> show (intercalate " " args))
        optionsF <- liftEffect commandOptions
        execa commandExecutable args optionsF
    )
    ( \e -> liftEffect $ throwMinsiError (errorConstructor (message e))
    )

shell :: Effect String
shell = isWindows <#> \win -> if win then "cmd.exe" else "/bin/sh"

commandOptions :: Effect (ExecaOptions -> ExecaOptions)
commandOptions = do
  sh <- shell
  pure (\options -> options { shell = Just sh, timeout = Just { killSignal: stringSignal "SIGTERM", milliseconds: Milliseconds 300000.0 } })

commandSyncOptions :: Effect (ExecaSyncOptions -> ExecaSyncOptions)
commandSyncOptions  = do
  sh <- shell
  pure (\options -> options { shell = Just sh, timeout = Just { killSignal: stringSignal "SIGTERM", milliseconds: Milliseconds 300000.0 } })
