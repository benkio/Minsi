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
import Web.HTML.HTMLDivElement (toNode)
import Web.DOM.Node (appendChild, removeChild, setTextContent)
import Web.DOM.Document (createElement)
import Web.DOM.Element (toNode) as E
import Web.HTML.HTMLUListElement as ULH
import Web.HTML.HTMLLIElement as LIH
import Web.HTML (window)
import Web.HTML.Window (document)
import Web.HTML.HTMLDocument (toDocument)
import Data.String (split)
import Data.String.Pattern (Pattern(..))
import Data.Traversable (traverse)
import Data.Maybe (Maybe(..))
import Main.MinsiErrors (MinsiError(..), throwMinsiError)

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
  errorList <- createErrorList errorMessage
  let minsiLogNode = toNode minsiLog
  let errorListNode = E.toNode (ULH.toElement errorList)
  appendChild errorListNode minsiLogNode
  void $ setTimeout 5000 do
    removeChild errorListNode minsiLogNode

createErrorList :: String -> Effect ULH.HTMLUListElement
createErrorList errorMessage = do
  let errorLines = split (Pattern "<br>") errorMessage
  w <- window
  htmlDoc <- document w
  doc <- pure $ toDocument htmlDoc
  ulElementRaw <- createElement "ul" doc
  ulElement <- case ULH.fromElement ulElementRaw of
    Nothing -> throwMinsiError (HTMLElementNotFound "ul")
    Just u -> pure u
  let ulNode = E.toNode (ULH.toElement ulElement)
  _ <- traverse (\line -> do
    liElementRaw <- createElement "li" doc
    liElement <- case LIH.fromElement liElementRaw of
      Nothing -> throwMinsiError (HTMLElementNotFound "li")
      Just l -> pure l
    let liNode = E.toNode (LIH.toElement liElement)
    setTextContent line liNode
    appendChild liNode ulNode
    ) errorLines
  pure ulElement
