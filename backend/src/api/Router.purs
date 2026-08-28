module Api.Router where

import Prelude

import Api.HttpLog (logIncomingPost)
import Controller.CheckDependenciesController (checkDependenciesController)
import Controller.ComputeController (computeController)
import Controller.ErrorHandlers (generalErrorHandler)
import Controller.DownloadController (downloadController)
import Controller.ResetController (resetController)
import Controller.StatusController (statusController)
import Controller.SubtitlesController (subtitlesController)
import Controller.UpdateCheckController (updateCheckController)
import Controller.UploadController (uploadController)
import InMemoryDB (Store)
import Middleware.MulterUpload (multerUploadMiddleware)
import Node.Express.App (App, get, post, useAtExternal)
import Node.Express.Handler (Handler)
import Node.Express.Response (setResponseHeader)

router :: Store -> App
router store = do
  post "/checkDependencies" (controllerLogic "/checkDependencies" (checkDependenciesController store))
  post "/compute" (controllerLogic "/compute" (computeController store))
  post "/status" (controllerLogic "/status" (statusController store))
  post "/subtitles" (controllerLogic "/subtitles" (subtitlesController store))
  get "/download/:videoId" (controllerLogic "/download" (downloadController store))
  post "/updateCheck" (controllerLogic "/updateCheck" (updateCheckController store))
  post "/reset" (controllerLogic "/reset" (resetController store))
  useAtExternal "/upload" multerUploadMiddleware
  post "/upload" (controllerLogic "/upload" (uploadController store))

defaultResponseSettings :: Handler
defaultResponseSettings = setResponseHeader "Access-Control-Allow-Origin" "*"

controllerLogic :: String -> Handler -> Handler
controllerLogic route logic =
  generalErrorHandler route $ defaultResponseSettings *> logIncomingPost route *> logic
