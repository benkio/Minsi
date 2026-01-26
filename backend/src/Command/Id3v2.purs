module Command.Id3v2 where

import Prelude

import Command.Command (runCommand)
import Constants (mp3)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import MinsiError (MinsiError(..))
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

addId3Tags :: FilePath -> String -> String -> Aff ExecaResult
addId3Tags filename artist title = do
  filepathMp3 <- liftEffect $ mp3 filename
  let args = addId3TagsArgs filepathMp3 artist title
  process <- runCommand args Id3v2Error "id3v2"
  process.getResult

addId3TagsArgs :: FilePath -> String -> String -> Array String
addId3TagsArgs filepathMp3 artist title =
  [ "-a", show artist, "-t", show title, filepathMp3 ]
