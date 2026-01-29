module Controller.ErrorHandlers where

import Prelude
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (message)
import Control.Monad.Error.Class (catchError)
import Node.Express.Handler (Handler)
import Node.Express.Response (setStatus, sendJson, end)

generalErrorHandler :: Handler -> Handler
generalErrorHandler handler =
  catchError handler
    ( \e -> do
        let errorMessage = message e
        liftEffect $ log errorMessage
        setStatus 500 *> sendJson { error: errorMessage } *> end
    )
