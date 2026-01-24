module Api.Router where

import Controller.ErrorHandlers (generalErrorHandler)

import Node.Express.Handler (Handler)
import Prelude
import Node.Express.App (App, post)
import Controller.CheckDependenciesController (checkDependenciesController)
import Node.Express.Response (setResponseHeader)
import Controller.ComputeController (computeController)
import Controller.StatusController (statusController)

router :: App
router = do
  post "/checkDependencies" (controllerLogic checkDependenciesController)
  post "/compute"           (controllerLogic computeController          )
  post "/status"            (controllerLogic statusController           )


defaultResponseSettings :: Handler
defaultResponseSettings = setResponseHeader "Access-Control-Allow-Origin" "*"

controllerLogic :: Handler -> Handler
controllerLogic logic = generalErrorHandler $ defaultResponseSettings *> logic
