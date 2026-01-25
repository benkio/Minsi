module Command.Command where

import Effect.Console (log)
import Data.Foldable (intercalate)

import Prelude
import Effect (Effect)
import Control.Monad.Error.Class (catchError)
import Effect.Exception (message)
import Node.ChildProcess (spawnSync)
import Node.ChildProcess.Types (Exit(..))
import Node.Buffer (Buffer)
import MinsiError (MinsiError, throwMinsiError)

runCommand :: Array String -> (String -> MinsiError) -> String -> Effect Buffer
runCommand args errorConstructor commandExecutable =
    catchError
    ( do
        log ("Execute Command: " <> commandExecutable <> " " <> show (intercalate " " args))
        result <- spawnSync commandExecutable args
        case result.exitStatus of
          Normally _ -> pure result.stdout
          e -> throwMinsiError (errorConstructor (show e))
    )
    ( \e -> throwMinsiError (errorConstructor (message e))
    )
