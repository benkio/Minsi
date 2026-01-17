module Api.Router where

import Prelude
import Node.Express.App (App, post)
import Controller.CheckDependenciesController (checkDependenciesController)
import Controller.CutVideoController (cutVideoController)

router :: App
router = do
  post "/checkDependencies" checkDependenciesController
  post "/cutVideo" cutVideoController
