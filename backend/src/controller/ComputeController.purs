module Controller.ComputeController where

import Prelude
import Effect.Class (liftEffect)
import Effect.Console (log)
import Data.Either (Either(Left, Right), either)
import Control.Monad.Except (runExcept)
import Model.State (State(..))
import Node.Express.Request (getBody)
import Node.Express.Handler (Handler)
import Node.Express.Response (end, setResponseHeader, setStatus)

computeController :: Handler
computeController = do
  setResponseHeader "Access-Control-Allow-Origin" "*"
  stateParsingResult :: _ (State) <- getBody
  case runExcept stateParsingResult of
    Left errors -> liftEffect $ log ("Failed to parse state: " <> show errors)
    Right (State state) -> liftEffect $ log ("Successfully parsed state - artist: " <> state.artist <> ", title: " <> state.title)
  setStatus 200 *> end
