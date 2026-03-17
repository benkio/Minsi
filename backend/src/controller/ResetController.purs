module Controller.ResetController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Constants (outputPath)
import Data.Either (Either(..), either)
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (message, try)
import InMemoryDB (Store, clearStore)
import Node.Express.Handler (Handler)
import Node.FS.Sync (readdir, rm)
import Node.Path (FilePath, resolve)

resetController :: Store -> Handler
resetController store = do
  liftEffect $ clearStore store
  liftEffect clearOutputFolder
  liftEffect $ log "[Reset Controller] In-memory DB cleared and output folder cleaned"
  respondJsonPost "/reset" 200 { status: "ok" }

clearOutputFolder :: Effect Unit
clearOutputFolder = do
  folder <- outputPath
  readdirResult <- try (readdir folder)
  case readdirResult of
    Left err -> log $ "[Reset Controller] Output folder missing or unreadable: " <> message err
    Right files -> traverse_ (\f -> if f /= ".gitignore" then deleteOutputFile folder f else pure unit) files

deleteOutputFile :: FilePath -> String -> Effect Unit
deleteOutputFile folder filename = do
  filePath <- resolve [ folder ] filename
  result <- try (rm filePath)
  either
    (\err -> log $ "[Reset Controller] Failed to delete " <> filePath <> ": " <> message err)
    (\_ -> log $ "[Reset Controller] Deleted output file: " <> filePath)
    result
