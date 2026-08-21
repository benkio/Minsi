module Api.HttpLog where

import Prelude

import Data.String.CodeUnits as SCU
import Effect.Class (liftEffect)
import Effect.Console (log)
import Foreign (Foreign)
import Node.Express.Handler (Handler, HandlerM(..))
import Node.Express.Response (end, sendJson, setStatus)
import Node.Express.Types (Request)
import Yoga.JSON (class WriteForeign, writeJSON)

foreign import _getReqBody :: Request -> Foreign
foreign import _stringify :: forall a. a -> String
foreign import _parseJson :: String -> Foreign

truncate :: Int -> String -> String
truncate n s =
  if SCU.length s > n then SCU.take n s <> "...(truncated)" else s

logIncomingPost :: String -> Handler
logIncomingPost route =
  HandlerM \req _ _ -> do
    let bodyStr = truncate 2000 (_stringify (_getReqBody req))
    liftEffect $ log $ "[HTTP] --> POST " <> route <> " body=" <> bodyStr
    pure unit

logOutgoingPost :: String -> Int -> Handler
logOutgoingPost route status =
  liftEffect $ log $ "[HTTP] <-- POST " <> route <> " " <> show status

respondJsonPost :: forall a. WriteForeign a => String -> Int -> a -> Handler
respondJsonPost route status body =
  let
    bodyStr = truncate 2000 (writeJSON body)
  in
    liftEffect (log $ "[HTTP] <-- POST " <> route <> " " <> show status <> " body=" <> bodyStr)
      *> setStatus status
      *> sendJson (_parseJson bodyStr)
      *> end

respondEmptyPost :: String -> Int -> Handler
respondEmptyPost route status =
  logOutgoingPost route status *> setStatus status *> end
