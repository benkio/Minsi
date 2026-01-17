module CheckDependencies.SoftwareCheck where

import Data.Foldable (foldM)
import Effect (Effect)
import Effect.Exception (catchException)
import Node.ChildProcess (spawnSync)
import Node.ChildProcess.Types (Exit(..))
import Prelude (pure, ($), (<$>), (<>))

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
checkSoftwareDependency command =
  catchException (\_ -> pure false) $
    ( \x -> case x.exitStatus of
        Normally _ -> true
        _ -> false
    )
      <$> spawnSync command [ "--version" ]
