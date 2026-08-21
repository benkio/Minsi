module CheckDependencies.SoftwareCheck where

import Data.Either (isRight)
import Data.Foldable (foldM)
import Effect (Effect)
import Effect.Exception (catchException)
import Node.Library.Execa.Which (whichSync, defaultWhichOptions)
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
  , "whisper"
  , "fc-list"
  ]

checkSoftwareDependency :: String -> Effect Boolean
checkSoftwareDependency command =
  catchException (\_ -> pure false) (isRight <$> (whichSync command defaultWhichOptions))
