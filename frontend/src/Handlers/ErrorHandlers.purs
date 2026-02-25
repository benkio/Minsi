module Handlers.ErrorHandlers where

import Components.HtmlComponents (loadDiv)
import Components.HtmlIds (minsiLogId, minsiErrorModalContentId, minsiErrorModalId)
import Components.Modal (showModal)
import Components.Window (getDocument, raiseErrorAlert)
import Control.Monad.Error.Class (catchError, class MonadError)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String (split)
import Data.String.Pattern (Pattern(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Class (liftEffect, class MonadEffect)
import Effect.Console (log)
import Effect.Exception (Error, message)
import Effect.Timer (setTimeout)
import Main.MinsiErrors (MinsiError(..), isCriticalError, throwMinsiError)
import Prelude
import Web.DOM.Document (createElement)
import Web.DOM.Element (toNode) as E
import Web.DOM.Node (appendChild, removeChild, setTextContent)
import Web.HTML (window)
import Web.HTML.HTMLDivElement (toNode)
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.HTMLLIElement as LIH
import Web.HTML.HTMLUListElement as ULH
import Web.HTML.Window (document)

-- | Runs an action and handles errors in both Effect and Aff using MonadError + MonadEffect.
genericErrorsHandler :: forall m. MonadError Error m => MonadEffect m => m Unit -> m Unit
genericErrorsHandler p =
  catchError p
    ( \e ->
        let
          errorMessage = message e
          handleError =
            if isCriticalError e then
              liftEffect (showMinsiErrorDialog errorMessage)
            else
              liftEffect (writeToMinsiLog errorMessage)
        in
          liftEffect (log errorMessage) *> catchError handleError (const (liftEffect (raiseErrorAlert errorMessage)))
    )

-- | Handles Either result (e.g. from runAff_ callback). Stays in Effect.
genericErrorsHandlerEither :: forall a. Either Error a -> Effect Unit
genericErrorsHandlerEither (Right _) = pure unit
genericErrorsHandlerEither (Left e) =
  let
    errorMessage = message e
    handleError =
      if isCriticalError e then
        showMinsiErrorDialog errorMessage
      else
        writeToMinsiLog errorMessage
  in
    log errorMessage *> catchError handleError (const (raiseErrorAlert errorMessage))

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

showMinsiErrorDialog :: String -> Effect Unit
showMinsiErrorDialog errorMessage = do
  doc <- getDocument
  minsiErrorModalContent <- loadDiv minsiErrorModalContentId doc
  errorList <- createErrorList errorMessage
  let minsiErrorModalContentNode = toNode minsiErrorModalContent
  let errorListNode = E.toNode (ULH.toElement errorList)
  appendChild errorListNode minsiErrorModalContentNode
  showModal minsiErrorModalId

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
  _ <- traverse
    ( \line -> do
        liElementRaw <- createElement "li" doc
        liElement <- case LIH.fromElement liElementRaw of
          Nothing -> throwMinsiError (HTMLElementNotFound "li")
          Just l -> pure l
        let liNode = E.toNode (LIH.toElement liElement)
        setTextContent line liNode
        appendChild liNode ulNode
    )
    errorLines
  pure ulElement
