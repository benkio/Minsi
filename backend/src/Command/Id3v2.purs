module Command.Id3v2 where

import Prelude

import Command.Command (runCommand)
import Config (currentVersion)
import Constants (mp3)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import MinsiErrors (MinsiError(..))
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

id3v2Timeout :: Maybe Milliseconds
id3v2Timeout = Just $ Milliseconds 5000.0

addId3Tags :: FilePath -> String -> String -> Aff ExecaResult
addId3Tags filename artist title = do
  filepathMp3 <- liftEffect $ mp3 filename
  let args = addId3TagsArgs filepathMp3 artist title
  process <- runCommand id3v2Timeout args Id3v2Error "id3v2"
  process.getResult

addId3TagsArgs :: FilePath -> String -> String -> Array String
addId3TagsArgs filepathMp3 artist title =
  [ "-a"
  , show artist
  , "-t"
  , show title
  , "--TSSE"
  , show ("Minsi-" <> currentVersion)
  , filepathMp3
  ]
