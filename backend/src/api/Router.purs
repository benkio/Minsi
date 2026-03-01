module Api.Router where

import Prelude

import Controller.CheckDependenciesController (checkDependenciesController)
import Controller.ComputeController (computeController)
import Controller.ErrorHandlers (generalErrorHandler)
import Controller.StatusController (statusController)
import Controller.UpdateCheckController (updateCheckController)
import Controller.UploadController (uploadController)
import InMemoryDB (Store)
import Middleware.MulterUpload (multerUploadMiddleware)
import Node.Express.App (App, post, useAtExternal)
import Node.Express.Handler (Handler)
import Node.Express.Response (setResponseHeader)

router :: Store -> App
router store = do
  post "/checkDependencies" (controllerLogic (checkDependenciesController store))
  post "/compute" (controllerLogic (computeController store))
  post "/status" (controllerLogic (statusController store))
  post "/updateCheck" (controllerLogic (updateCheckController store))
  useAtExternal "/upload" multerUploadMiddleware
  post "/upload" (controllerLogic (uploadController store))

defaultResponseSettings :: Handler
defaultResponseSettings = setResponseHeader "Access-Control-Allow-Origin" "*"

controllerLogic :: Handler -> Handler
controllerLogic logic = generalErrorHandler $ defaultResponseSettings *> logic
