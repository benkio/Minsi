module Middleware.Middlewares where

import Prelude

import Effect.Class (liftEffect)
import Node.Express.App (App, useExternal)
import Middleware.Helmet (helmet)
import Middleware.PublicMiddleware (publicMiddleware)
import Middleware.BodyParserMiddleware (jsonBodyParser)

registerMiddlewares :: App
registerMiddlewares = do
  useExternal helmet
  useExternal jsonBodyParser
  middleware <- liftEffect publicMiddleware
  useExternal middleware
