module Controller.CheckDependenciesController where

import Prelude (bind, (*>), (<$>), (<*>), (<>))

import CheckDependencies.FontCheck (checkFontDependencies)
import CheckDependencies.SoftwareCheck (checkSoftwareDependencies)
import Data.Foldable (null)
import Effect (Effect)
import Effect.Class (liftEffect)
import InMemoryDB (Store)
import Node.Express.Handler (Handler)
import Node.Express.Response (end, sendJson, setStatus)
import Response.CheckDependenciesResponse (buildResponse)

checkDependenciesController :: Store -> Handler
checkDependenciesController _store = do
  failedDependencies <- liftEffect checkDependecies
  if null failedDependencies then setStatus 200 *> end
  else setStatus 500 *> sendJson (buildResponse failedDependencies)

checkDependecies :: Effect (Array String)
checkDependecies =
  (<>) <$> checkFontDependencies <*> checkSoftwareDependencies
