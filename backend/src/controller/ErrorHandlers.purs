module Controller.ErrorHandlers where

import Prelude
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (message)
import Control.Monad.Error.Class (catchError)
import Api.HttpLog (respondJsonPost)
import Node.Express.Handler (Handler)

generalErrorHandler :: String -> Handler -> Handler
generalErrorHandler route handler =
  catchError handler
    ( \e -> do
        let errorMessage = message e
        liftEffect $ log errorMessage
        respondJsonPost route 500 { error: errorMessage }
    )
