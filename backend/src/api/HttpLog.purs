module Api.HttpLog where

import Prelude

import Effect.Class (liftEffect)
import Effect.Console (log)
import Node.Express.Handler (Handler)
import Node.Express.Response (end, sendJson, setStatus)

logIncomingPost :: String -> Handler
logIncomingPost route =
  liftEffect $ log $ "[HTTP] --> POST " <> route

logOutgoingPost :: String -> Int -> Handler
logOutgoingPost route status =
  liftEffect $ log $ "[HTTP] <-- POST " <> route <> " " <> show status

respondJsonPost :: forall a. String -> Int -> a -> Handler
respondJsonPost route status body =
  logOutgoingPost route status *> setStatus status *> sendJson body *> end

respondEmptyPost :: String -> Int -> Handler
respondEmptyPost route status =
  logOutgoingPost route status *> setStatus status *> end
