module CheckDependencies.SoftwareCheck where

import Effect.Console (log)
import Data.Foldable (foldM)
import Effect (Effect)
import Effect.Exception (catchException, message)
import Node.ChildProcess (execSync)
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
  [ "ffmpeg -version"
  , "yt-dlp --version"
  , "id3v2 --version"
  , "fc-list --version"
  ]

checkSoftwareDependency :: String -> Effect Boolean
checkSoftwareDependency command =
  catchException (\e -> log (message e) *> pure false) (const true <$> execSync command)
