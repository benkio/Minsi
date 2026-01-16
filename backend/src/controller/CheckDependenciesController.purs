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
import Node.Express.Response (end, sendJson, setStatus)
import Prelude

softwareDependencies :: Array String
softwareDependencies =
    [ "ffmpeg"
    , "yt-dlp"
    , "id3v2"
    , "fc-list"
    ]

fontDependencies :: Array String
fontDependencies =
    [ "Impact"
    , "Arial Black"
    ]

checkDependenciesController :: Handler
checkDependenciesController = do
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

checkSoftwareDependency :: String -> Effect Boolean
checkSoftwareDependency command =
    catchException (\_ -> pure false) $
        ( \x -> case x . exitStatus of
            Normally _ -> true
            _ -> false
        )
            <$> spawnSync command ["--version"]

checkFontDependencies :: Effect (Array String)
checkFontDependencies =
    foldM
        ( \acc font ->
            ((\x -> if x then acc else acc <> [font])) <$> fcListSearch font
        )
        []
        fontDependencies

fcListSearch :: String -> Effect Boolean
fcListSearch font = do
    fontListResult <- spawnSync "fc-list" []
    case fontListResult . exitStatus of
        Normally _ -> any (includes font) <<< lines <$> toString UTF8 fontListResult . stdout
        _ -> pure false
