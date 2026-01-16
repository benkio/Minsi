module Middleware.PublicMiddleware where

import Node.Express.Middleware.Static as Static
import Node.Path (FilePath, concat)
import Node.Express.Types
import Effect (Effect)

publicDir :: FilePath
publicDir = concat ["..", "public"]

publicMiddleware :: Effect Middleware
publicMiddleware = Static.static publicDir
