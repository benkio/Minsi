module Controller.CheckDependenciesController where

import Control.Apply ((<*>))
import Data.Foldable (foldM)
import Effect (Effect)
import Node.ChildProcess (spawnSync)
import Node.ChildProcess.Types (Exit (..))
import Node.Express.Handler (Handler)
import Node.Express.Response (sendJson)
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
checkDependenciesController = sendJson{}

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
    ( \x -> case x . exitStatus of
        Normally _ -> true
        _ -> false
    )
        <$> spawnSync command ["--version"]

checkFontDependencies :: Effect (Array String)
checkFontDependencies = pure []

-- const { spawnSync } = require('child_process');

-- function isInstalled(cmd) {
--   const result = spawnSync(cmd, ['--version'], { stdio: 'ignore' });
--   return result.status === 0;
-- }

-- console.log(isInstalled('node')); // true
