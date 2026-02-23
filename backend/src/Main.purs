module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Job.CleanupOutput (runCleanupJob)
import Node.Express.App (App, listenHttp)
import Node.Express.Types (Port(..))
import Middleware.Middlewares (registerMiddlewares)
import Api.Router (router)
import InMemoryDB (Store, initStore)

main :: Effect Unit
main = do
  store <- initStore
  runCleanupJob
  let
    port = Port 8080
    app = buildApp store
  _ <- listenHttp app port \_ -> do
    log $ "Server listening on http://localhost:8080"
  pure unit

buildApp :: Store -> App
buildApp store = do
  registerMiddlewares
  router store
