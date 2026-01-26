module CheckDependencies.SoftwareCheck where

import Node.Library.Execa (execaCommandSync)
import Data.Either (isRight)
import Effect.Console (log)
import Data.Foldable (foldM)
import Effect (Effect)
import Effect.Exception (catchException, message)
import Prelude
import Node.Library.Execa.Which (whichSync, defaultWhichOptions)

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
  catchException (\e -> log (message e) *> pure false) (isRight <$> whichSync command defaultWhichOptions)
