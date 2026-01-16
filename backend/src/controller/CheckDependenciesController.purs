module Controller.CheckDependenciesController where

import Node.Express.Response (sendJson)
import Node.Express.Handler (Handler)

checkDependenciesController :: Handler
checkDependenciesController = sendJson {}
