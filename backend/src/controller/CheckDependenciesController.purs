module Controller.CheckDependenciesController where

import CheckDependencies.FontCheck (checkFontDependencies)
import CheckDependencies.SoftwareCheck (checkSoftwareDependencies)
import Data.Foldable (null)
import Effect (Effect)
import Effect.Class (liftEffect)
import Node.Express.Handler (Handler)
import Node.Express.Response (end, sendJson, setResponseHeader, setStatus)
import Prelude (bind, discard, (*>), (<$>), (<*>), (<>))

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
