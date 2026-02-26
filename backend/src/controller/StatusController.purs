module Controller.StatusController where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Maybe (maybe)
import Effect.Class (liftEffect)
import Effect.Console (log)
import InMemoryDB (Store, lookupProcessStatus)
import Model.ProcessStatus (ProcessStatus)
import Node.Express.Handler (Handler)
import Node.Express.Request (getBody)
import Node.Express.Response (sendJson, setStatus, end)
import Response.StatusResponse (buildResponse)

statusController :: Store -> Handler
statusController store = do
  bodyResult <- getBody
  either badRequest (handleStatus store) (runExcept bodyResult)

badRequest :: forall a. Show a => a -> Handler
badRequest errors = do
  liftEffect $ log ("Failed to parse request body: " <> show errors)
  setStatus 400 *> sendJson { error: "Bad Request" } *> end

handleStatus :: Store -> { filename :: String } -> Handler
handleStatus store body = do
  maybeStatus <- liftEffect $ lookupProcessStatus body.filename store
  maybe notFound (respondWithStatus <<< _.processStatus) maybeStatus

notFound :: Handler
notFound = setStatus 404 *> sendJson { error: "Not found" } *> end

respondWithStatus :: ProcessStatus -> Handler
respondWithStatus status =
  setStatus 200 *> sendJson (buildResponse status) *> end
