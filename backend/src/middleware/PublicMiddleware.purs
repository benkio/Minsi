module Middleware.PublicMiddleware where

import Constants (publicDir)
import Node.Express.Middleware.Static as Static
import Node.Express.Types
import Effect (Effect)

publicMiddleware :: Effect Middleware
publicMiddleware = Static.static publicDir
