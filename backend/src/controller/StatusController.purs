module Controller.StatusController where

import Prelude

import Api.HttpLog (respondJsonPost)
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Maybe (maybe)
import Domain.ProcessStatus (ProcessStatus)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store, lookupProcessStatus)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Response.StatusResponse (buildResponse)

statusController :: Store -> Handler
statusController store = do
  bodyResult <- getBody
  either badRequest (handleStatus store) (runExcept bodyResult)

badRequest :: forall a. Show a => a -> Handler
badRequest errors = do
  liftEffect $ log ("Failed to parse request body: " <> show errors)
  respondJsonPost "/status" 400 { error: "Bad Request" }

handleStatus :: Store -> { filename :: String } -> Handler
handleStatus store body = do
  maybeStatus <- liftEffect $ lookupProcessStatus body.filename store
  maybe notFound (respondWithStatus <<< _.processStatus) maybeStatus

notFound :: Handler
notFound = respondJsonPost "/status" 404 { error: "Not found" }

respondWithStatus :: ProcessStatus -> Handler
respondWithStatus status =
  respondJsonPost "/status" 200 (buildResponse status)
