module Job.CleanupOutput where

import Prelude

import Constants (outputPath)
import Data.DateTime.Instant (unInstant)
import Data.Foldable (traverse_)
import Data.String.Utils (endsWith)
import Data.Time.Duration (Milliseconds(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff, delay, launchAff_, apathize, catchError)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Now (now)
import Node.FS.Stats (birthtimeMs, isFile)
import Node.FS.Sync (readdir, stat, rm)
import Node.Path (FilePath, resolve)

-- | Delete files in public/output older than the given number of milliseconds.
-- | No-op if the directory does not exist.
cleanupOutputFolder :: Milliseconds -> Aff Unit
cleanupOutputFolder maxAge =
  catchError run \_ -> liftEffect $ log "[CleanupOutput] Output directory not found or not readable, skipping."
  where
  run = do
    dir <- liftEffect outputPath
    entries <- liftEffect $ readdir dir
    currentInstant <- liftEffect now
    let (Milliseconds currentMs) = unInstant currentInstant
    let maxAgeMs = case maxAge of Milliseconds n -> n
    filePaths <- liftEffect $ traverse (\name -> resolve [ dir ] name) entries
    traverse_ (tryDeleteIfOld currentMs maxAgeMs) filePaths

tryDeleteIfOld :: Number -> Number -> FilePath -> Aff Unit
tryDeleteIfOld currentMs maxAgeMs filePath =
  apathize $ liftEffect do
    s <- stat filePath
    let (Milliseconds fileMs) = birthtimeMs s
    if isFile s && (currentMs - fileMs) > maxAgeMs && endsWith ".gitignore" filePath then log ("[CleanupOutput] Delete (older than 1h): " <> filePath) *> rm filePath
    else pure unit

-- | Run the cleanup job in the background: every hour, delete files in
-- | public/output older than 1 hour. Call once at server start.
runCleanupJob :: Effect Unit
runCleanupJob =
  launchAff_ $ loop
  where
  loop :: Aff Unit
  loop = do
    cleanupOutputFolder (Milliseconds 3600000.0)
    delay (Milliseconds 3600000.0)
    loop
