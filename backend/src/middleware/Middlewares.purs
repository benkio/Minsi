module Middleware.Middlewares where

import Prelude

import Effect.Class (liftEffect)
import Middleware.PublicMiddleware
import Node.Express.App (App, useExternal)

registerMiddlewares :: App
registerMiddlewares = do
  middleware <- liftEffect publicMiddleware
  useExternal middleware
