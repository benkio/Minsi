module CheckDependencies.FontCheck where

import Data.Time.Duration (Milliseconds(..))

import Node.ChildProcess.Types (stringSignal)
import Node.ChildProcess (execSync)
import Node.Encoding (Encoding(..))
import Node.Buffer (toString)
import Node.Library.Execa.Which (isWindows)
import Effect.Console (log)
import Node.Library.Execa (execaCommandSync)
import Control.Monad.Error.Class (catchError)
import Control.Monad.Loops (anyM)
import Data.Array (catMaybes, partition)
import Data.Maybe (Maybe(..))
import Data.Either (hush)
import Data.Foldable (foldM)
import Data.Functor ((<#>))
import Data.HeytingAlgebra ((||))
import Data.List (fromFoldable, filterM, List)
import Data.String (contains, toLower)
import Data.String.Common (replaceAll)
import Data.String.Pattern (Pattern(..), Replacement(..))
import Data.String.Utils (includes, lines)
import Data.Traversable (any, traverse)
import Data.Tuple (Tuple(..), fst, snd)
import Effect (Effect)
import Effect.Console (error)
import Effect.Exception (catchException, message, try)
import Node.FS.Stats (isDirectory)
import Node.FS.Sync (readdir, stat, exists)
import Node.Path (FilePath, basename, normalize)
import Prelude

fontDependencies :: Array String
fontDependencies =
  [ "Impact"
  , "Arial Black"
  ]

knownFontFolders :: Effect (List FilePath)
knownFontFolders =
  ( fromFoldable >>> map normalize >>>
      filterM
        ( \p -> exists p >>=
            \e ->
              if e then isDirectory <$> stat p
              else pure e
        )
  )
    [ "/System/Library/Fonts"
    , "/Library/Fonts"
    , "/Windows/Fonts"
    , "/usr/share/fonts"
    , "~/.local/share/fonts"
    , "~/.nix-profile/share/fonts"
    ]

checkFontDependencies :: Effect (Array String)
checkFontDependencies =
  foldM
    ( \acc font ->
        ((\x -> if x then acc else acc <> [ font ])) <$> searchFont font
    )
    []
    fontDependencies

-- Search Font --------------------------------------------------------

searchFont :: String -> Effect Boolean
searchFont font = do
  fcListResult <- fcListSearch font
  searchDirResult <- searchFontInDirs font
  pure (fcListResult || searchDirResult)

fcListSearch :: String -> Effect Boolean
fcListSearch font = catchException (\e -> error (message e) *> pure false) $ do
  log ("Execute Command: fc-list")
  stringResult <- execSync "fc-list" >>= toString UTF8
  pure $ any (includes font) <<< lines $ stringResult

searchFontInDirs :: String -> Effect Boolean
searchFontInDirs font = do
  fontFolders <- knownFontFolders
  catchError (anyM (searchFontInDir font) fontFolders) (\e -> error (message e) *> pure false)

searchFontInDir :: String -> FilePath -> Effect Boolean
searchFontInDir font dir = catchError check (\e -> error (message e) *> pure false)
  where
  check = do
    dirFiles <-
      readdir dir
        <#> map (\f -> dir <> "/" <> f)
        >>= traverse (\f -> map (\s -> Tuple s f) <<< hush <$> try (stat f))
        <#> catMaybes
    let { no: files, yes: dirs } = partition (fst >>> isDirectory) dirFiles
    if any (snd >>> checkFileMatch font) files then
      pure true
    else
      anyM (snd >>> searchFontInDir font) (fromFoldable dirs)

checkFileMatch :: String -> String -> Boolean
checkFileMatch font file =
  any (\n -> (Pattern n) `contains` (basename >>> toLower) file) $
    toLower <$> [ font, replaceAll (Pattern " ") (Replacement "_") font ]
