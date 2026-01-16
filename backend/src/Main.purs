module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.Express.App (App, listenHttp)
import Node.Express.Types (Port (..))
import Middleware.Middlewares (registerMiddlewares)
import Api.Router (router)

main :: Effect Unit
main = do
    -- Start the server
    let port = Port 8080
        app = buildApp
    _ <- listenHttp app port \_ -> do
        log $ "Server listening on http://localhost:8080"
    pure unit

buildApp :: App
buildApp = do
  registerMiddlewares
  router
