module CheckDependencies.FontCheck where

import Control.Monad.Error.Class (catchError)
import Control.Monad.Loops (anyM)
import Data.Array (catMaybes, partition)
import Data.Either (hush)
import Data.Foldable (foldM)
import Data.Functor ((<#>))
import Data.HeytingAlgebra ((||))
import Data.List (fromFoldable)
import Data.String (contains, toLower)
import Data.String.Common (replaceAll)
import Data.String.Pattern (Pattern(..), Replacement(..))
import Data.String.Utils (includes, lines)
import Data.Traversable (any, traverse)
import Data.Tuple (Tuple(..), fst, snd)
import Effect (Effect)
import Effect.Console (error)
import Effect.Exception (catchException, message, try)
import Node.Buffer (toString)
import Node.ChildProcess (spawnSync)
import Node.ChildProcess.Types (Exit(..))
import Node.Encoding (Encoding(..))
import Node.FS.Stats (isDirectory)
import Node.FS.Sync (readdir, stat)
import Node.Path (FilePath, basename, normalize)
import Prelude (bind, map, pure, ($), (*>), (<$>), (<<<), (<>), (>>=), (>>>))

fontDependencies :: Array String
fontDependencies =
  [ "Impact"
  , "Arial Black"
  ]

knownFontFolders :: Array FilePath
knownFontFolders =
  map
    normalize
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
  fontListResult <- spawnSync "fc-list" []
  case fontListResult.exitStatus of
    Normally _ -> any (includes font) <<< lines <$> toString UTF8 fontListResult.stdout
    _ -> pure false

searchFontInDirs :: String -> Effect Boolean
searchFontInDirs font =
  catchError (anyM (searchFontInDir font) (fromFoldable knownFontFolders)) (\e -> error (message e) *> pure false)

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
    if any (snd >>> checkFileMatch font) files then pure true
    else anyM (snd >>> searchFontInDir font) (fromFoldable dirs)

checkFileMatch :: String -> String -> Boolean
checkFileMatch font file =
  any (\n -> (Pattern n) `contains` (basename >>> toLower) file) $
    toLower <$> [ font, replaceAll (Pattern " ") (Replacement "_") font ]
