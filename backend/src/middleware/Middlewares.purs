module Middleware.Middlewares where

import Prelude (bind)

import Effect.Class (liftEffect)
import Node.Express.App (App, useExternal)
import Middleware.PublicMiddleware (publicMiddleware)

registerMiddlewares :: App
registerMiddlewares = do
  middleware <- liftEffect publicMiddleware
  useExternal middleware
