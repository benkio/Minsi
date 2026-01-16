module Api.Router where

import Node.Express.App (App, post)
import Controller.CheckDependenciesController (checkDependenciesController)

router :: App
router = do
  post "/checkDependencies" checkDependenciesController
