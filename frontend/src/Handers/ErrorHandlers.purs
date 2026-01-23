module Handers.ErrorHandlers where

import Components.HtmlIds (minsiLogId)
import Prelude
import Components.HtmlComponents (loadDiv)
import Components.Window (getDocument, raiseErrorAlert)
import Effect (Effect)
import Effect.Timer (setTimeout)
import Effect.Exception (Error, message)
import Control.Monad.Error.Class (catchError)
import Data.Either (Either(..))
import Web.DOM.Node (setTextContent)
import Web.HTML.HTMLDivElement (toNode)

genericErrorsHandler :: Effect Unit -> Effect Unit
genericErrorsHandler p =
  catchError p
    ( \e ->
        catchError (writeToMinsiLog (message e)) (const (raiseErrorAlert (message e)))
    )

genericErrorsHandlerEither :: forall a. Either Error a -> Effect Unit
genericErrorsHandlerEither (Right _) = pure unit
genericErrorsHandlerEither (Left e) = catchError (writeToMinsiLog (message e)) (const (raiseErrorAlert (message e)))

writeToMinsiLog :: String -> Effect Unit
writeToMinsiLog errorMessage = do
  doc <- getDocument
  minsiLog <- loadDiv minsiLogId doc
  let minsiLogNode = toNode minsiLog
  setTextContent errorMessage minsiLogNode
  void $ setTimeout 5000 do
    setTextContent "" minsiLogNode
