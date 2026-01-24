module Controller.ComputeController where

import Prelude
import Effect.Class (liftEffect)
import Effect.Console (log)
import Data.Either (Either(Left, Right))
import Control.Monad.Except (runExcept)
import Model.ProcessStatus (ProcessStatus(..))
import Model.State (State(..))
import Node.Express.Request (getBody)
import Node.Express.Handler (Handler)
import Node.Express.Response (sendJson, setResponseHeader, setStatus, end)

computeController :: Handler
computeController = do
  stateParsingResult :: _ (State) <- getBody
  case runExcept stateParsingResult of
    Left errors ->
      liftEffect $ log ("Failed to parse state: " <> show errors)
    Right (State state) ->
      liftEffect $
        log
          ( "Successfully parsed state - artist: " <> state.artist <> ", title: "
              <> state.title
          )
  --TODO: Add a simple async shell call to echo and log it for now
  setStatus 200 *> end
