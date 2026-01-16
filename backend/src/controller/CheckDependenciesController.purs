module Controller.CheckDependenciesController where

import Data.Foldable (any, foldM, null)
import Data.String.Utils (includes, lines)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Exception (catchException)
import Node.Buffer (toString)
import Node.ChildProcess (spawnSync)
import Node.ChildProcess.Types (Exit (..))
import Node.Encoding (Encoding (..))
import Node.Express.Handler (Handler)
import Node.Express.Response (end, sendJson, setStatus, setResponseHeader)
import Prelude

checkDependenciesController :: Handler
checkDependenciesController = do
    setResponseHeader "Access-Control-Allow-Origin" "*"
    failedDependencies <- liftEffect checkDependecies
    if null failedDependencies
        then setStatus 200 *> end
        else setStatus 500 *> sendJson{missedDependencies: failedDependencies}

checkDependecies :: Effect (Array String)
checkDependecies =
    (<>) <$> checkFontDependencies <*> checkSoftwareDependencies

checkSoftwareDependencies :: Effect (Array String)
checkSoftwareDependencies =
    foldM
        ( \acc command ->
            ((\x -> if x then acc else acc <> [command])) <$> checkSoftwareDependency command
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
        ( \x -> case x . exitStatus of
            Normally _ -> true
            _ -> false
        )
            <$> spawnSync command ["--version"]

fontDependencies :: Array String
fontDependencies =
    [ "Impact"
    , "Arial Black"
    ]

--TODO: Search in these folders for fonts
-- knownFontFolders :: Array FilePath
-- knownFontFolders = [
--     os.root / "System" / "Library" / "Fonts",
--     os.root / "Windows" / "Fonts",
--     os.root / "usr" / "share" / "fonts",
--     os.home / ".local" / "share" / "fonts",
--     os.home / ".nix-profile" / "share" / "fonts"
--                    ]

checkFontDependencies :: Effect (Array String)
checkFontDependencies =
    foldM
        ( \acc font ->
            ((\x -> if x then acc else acc <> [font])) <$> fcListSearch font
        )
        []
        fontDependencies

fcListSearch :: String -> Effect Boolean
fcListSearch font =   catchException (\_ -> pure false) $ do
    fontListResult <- spawnSync "fc-list" []
    case fontListResult . exitStatus of
        Normally _ -> any (includes font) <<< lines <$> toString UTF8 fontListResult . stdout
        _ -> pure false
