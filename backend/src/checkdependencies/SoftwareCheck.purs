module CheckDependencies.SoftwareCheck where

import Command.Command (commandSyncOptions, shell)
import Node.Library.Execa (execaSync)
import Data.Foldable (any, foldM)
import Data.Traversable (traverse)
import Effect.Console (log)
import Effect (Effect)
import Effect.Exception (catchException, message)
import Prelude

-- Check Software Dependecies ---------------------------------------------

checkSoftwareDependencies :: Effect (Array String)
checkSoftwareDependencies =
  foldM
    ( \acc command ->
        ((\x -> if x then acc else acc <> [ command ])) <$> checkSoftwareDependency command
    )
    []
    softwareDependencies

softwareDependencies :: Array String
softwareDependencies =
  [ "ffmpeg"
  , "yt-dlp"
  , "id3v2"
  , "fc-list"
  ]

checkSoftwareDependency :: String -> Effect Boolean
checkSoftwareDependency command = do
  commandOptionsF <- commandSyncOptions
  sh <- shell
  any identity <$> traverse (tryCommand sh commandOptionsF) commands
  where
    commands =
      [ "which " <> command
      , command <> " --version"
      , command <> " -version"
      ]
    tryCommand sh opts c =
      catchException (\e -> log (message e) *> pure false) (execaSync sh [ "-c", c ] opts $> true)
