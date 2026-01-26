module Api.Router where

import Prelude

import Controller.CheckDependenciesController (checkDependenciesController)
import Controller.ComputeController (computeController)
import Controller.ErrorHandlers (generalErrorHandler)
import Controller.StatusController (statusController)
import InMemoryDB (Store)
import Node.Express.App (App, post)
import Node.Express.Handler (Handler)
import Node.Express.Response (setResponseHeader)

router :: Store -> App
router store = do
  post "/checkDependencies" (controllerLogic (checkDependenciesController store))
  post "/compute" (controllerLogic (computeController store))
  post "/status" (controllerLogic (statusController store))

defaultResponseSettings :: Handler
defaultResponseSettings = setResponseHeader "Access-Control-Allow-Origin" "*"

controllerLogic :: Handler -> Handler
controllerLogic logic = generalErrorHandler $ defaultResponseSettings *> logic
