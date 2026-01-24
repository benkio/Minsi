module Controller.ComputeController where

import Effect (Effect)

import Prelude
import Effect.Class (liftEffect)
import Effect.Console (log)
import Data.Either (Either(Left, Right))
import Control.Monad.Except (runExcept)
import Model.State (State(..))
import Node.Express.Request (getBody)
import Node.Express.Handler (Handler)
import Node.Express.Response (sendJson, setStatus, end)
import Node.ChildProcess (execSync)
import Node.Buffer (toString)
import Node.Encoding (Encoding(..))

computeController :: Handler
computeController = do
  stateParsingResult <- getBody
  case runExcept stateParsingResult of
    Left errors -> do
      liftEffect $ log ("Failed to parse state: " <> show errors)
      setStatus 400 *> sendJson { error: "Bad Request: Failed to parse state" } *> end
    Right state -> liftEffect (compute state) *> setStatus 200 *> end

compute :: State -> Effect Unit
compute _ = do
  resultBuffer <- execSync "echo whoowhooo"
  result <- toString UTF8 resultBuffer
  log result

