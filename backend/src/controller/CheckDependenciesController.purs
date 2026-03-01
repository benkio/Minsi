module Controller.CheckDependenciesController where

import Prelude (bind, (<$>), (<*>), (<>))

import Api.HttpLog (respondEmptyPost, respondJsonPost)
import CheckDependencies.FontCheck (checkFontDependencies)
import CheckDependencies.SoftwareCheck (checkSoftwareDependencies)
import Data.Foldable (null)
import Effect (Effect)
import Effect.Class (liftEffect)
import InMemoryDB (Store)
import Node.Express.Handler (Handler)
import Response.CheckDependenciesResponse (buildResponse)

checkDependenciesController :: Store -> Handler
checkDependenciesController _store = do
  failedDependencies <- liftEffect checkDependecies
  if null failedDependencies then respondEmptyPost "/checkDependencies" 200
  else respondJsonPost "/checkDependencies" 500 (buildResponse failedDependencies)

checkDependecies :: Effect (Array String)
checkDependecies =
  (<>) <$> checkFontDependencies <*> checkSoftwareDependencies
