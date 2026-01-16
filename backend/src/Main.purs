module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.Express.App (App, listenHttp, useExternal)
import Node.Express.Middleware.Static as Static
import Node.Express.Types (Port (..))
import Node.Path as Path

main :: Effect Unit
main = do
    -- Path to public folder (relative to backend directory)
    let publicDir = Path.concat ["..", "public"]

    -- Create static middleware
    staticMiddleware <- Static.static publicDir

    -- Build the Express app with static middleware
    let appSetup :: App
        appSetup = useExternal staticMiddleware

    -- Start the server
    let port = Port 8080
    _ <- listenHttp appSetup port \_ -> do
        log $ "Server listening on http://localhost:8080"
    pure unit
