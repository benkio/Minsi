module Middleware.BodyParserMiddleware where

import Node.Express.Types (Middleware)

foreign import jsonBodyParser :: Middleware
