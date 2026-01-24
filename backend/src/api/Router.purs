module Api.Router where

import Node.Express.Handler (Handler)
import Prelude
import Node.Express.App (App, post)
import Controller.CheckDependenciesController (checkDependenciesController)
import Node.Express.Response (setResponseHeader)
import Controller.ComputeController (computeController)
import Controller.StatusController (statusController)

router :: App
router = do
  post "/checkDependencies" (defaultResponseSettings *> checkDependenciesController)
  post "/compute"           (defaultResponseSettings *> computeController          )
  post "/status"            (defaultResponseSettings *> statusController           )


defaultResponseSettings :: Handler
defaultResponseSettings = setResponseHeader "Access-Control-Allow-Origin" "*"
