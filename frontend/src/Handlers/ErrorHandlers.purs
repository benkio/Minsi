module Handlers.ErrorHandlers where

import Prelude

import Components.HTMLCollection (swapClasses)
import Components.HTMLComponentsLoader (loadHtmlElementClass)
import Components.HtmlComponents (loadDiv)
import Components.HtmlIdAndClasses (minsiBlockingModalId, minsiErrorModalContentId, minsiErrorModalId, minsiLogBoxClass, minsiLogId, minsiLogTitleId)
import Components.Modal (setBlockingModalBody, showModal)
import Components.Window (getDocument, raiseErrorAlert)
import Control.Monad.Error.Class (catchError, class MonadError)
import Data.Either (Either, either)
import Data.Maybe (Maybe(..), isJust, maybe)
import Data.String (split)
import Data.String.CodeUnits (stripPrefix)
import Data.String.Pattern (Pattern(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Class (liftEffect, class MonadEffect)
import Effect.Console (log)
import Effect.Exception (Error, message)
import Effect.Timer (setTimeout)
import Main.MinsiErrors (ErrorSeverity(..), MinsiError(..), getErrorSeverity, throwMinsiError)
import Web.DOM.Document (Document, createElement)
import Web.DOM.Element (toNode) as E
import Web.DOM.Node (Node, appendChild, removeChild, setTextContent)
import Web.HTML (window)
import Web.HTML.HTMLAnchorElement as HA
import Web.HTML.HTMLDivElement (toElement, toNode)
import Web.HTML.HTMLDivElement as HD
import Web.HTML.HTMLDocument (toDocument)
import Web.HTML.HTMLHyperlinkElementUtils (setHref)
import Web.HTML.HTMLLIElement as LIH
import Web.HTML.HTMLParagraphElement as HP
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
            case getErrorSeverity e of
              Fatal -> liftEffect (showMinsiBlockingErrorDialog errorMessage)
              Critical -> liftEffect (showMinsiErrorDialog errorMessage)
              Standard -> liftEffect (writeToMinsiLog errorMessage)
        in
          liftEffect (log errorMessage) *> catchError handleError (const (liftEffect (raiseErrorAlert errorMessage)))
    )

-- | Handles Either result (e.g. from runAff_ callback). Stays in Effect.
genericErrorsHandlerEither :: forall a. Either Error a -> Effect Unit
genericErrorsHandlerEither = either
  ( \e ->
      let
        errorMessage = message e
        handleError =
          case getErrorSeverity e of
            Fatal -> liftEffect (showMinsiBlockingErrorDialog errorMessage)
            Critical -> liftEffect (showMinsiErrorDialog errorMessage)
            Standard -> liftEffect (writeToMinsiLog errorMessage)
      in
        log errorMessage *> catchError handleError (const (raiseErrorAlert errorMessage))
  )
  (const (pure unit))

writeToMinsiLog :: String -> Effect Unit
writeToMinsiLog errorMessage = do
  doc <- getDocument
  minsiLog <- loadDiv minsiLogId doc
  minsiLogTitle <- loadDiv minsiLogTitleId doc
  logBoxElements <- loadHtmlElementClass minsiLogBoxClass doc
  errorList <- createErrorList errorMessage
  let minsiLogNode = toNode minsiLog
  let minsiLogTitleNode = E.toNode (toElement minsiLogTitle)
  let errorListNode = E.toNode (ULH.toElement errorList)
  appendChild errorListNode minsiLogNode
  swapClasses "border-success" "border-danger" logBoxElements
  setTextContent "\x1F63E MINSI LOG \x1F63E" minsiLogTitleNode
  void $ setTimeout 5000 do
    removeChild errorListNode minsiLogNode
    swapClasses "border-danger" "border-success" logBoxElements
    setTextContent "\x1F63A MINSI LOG \x1F63A" minsiLogTitleNode

showMinsiErrorDialog :: String -> Effect Unit
showMinsiErrorDialog errorMessage = do
  doc <- getDocument
  minsiErrorModalContent <- loadDiv minsiErrorModalContentId doc
  errorList <- createErrorList errorMessage
  let minsiErrorModalContentNode = toNode minsiErrorModalContent
  let errorListNode = E.toNode (ULH.toElement errorList)
  appendChild errorListNode minsiErrorModalContentNode
  showModal minsiErrorModalId (Just 5000)

createErrorList :: String -> Effect ULH.HTMLUListElement
createErrorList errorMessage = do
  let errorLines = split (Pattern "<br>") errorMessage
  w <- window
  htmlDoc <- document w
  doc <- pure $ toDocument htmlDoc
  ulElementRaw <- createElement "ul" doc
  ulElement <- maybe (throwMinsiError (HTMLElementNotFound "ul")) pure (ULH.fromElement ulElementRaw)
  let ulNode = E.toNode (ULH.toElement ulElement)
  _ <- traverse
    ( \line -> do
        liElementRaw <- createElement "li" doc
        liElement <- maybe (throwMinsiError (HTMLElementNotFound "li")) pure (LIH.fromElement liElementRaw)
        let liNode = E.toNode (LIH.toElement liElement)
        appendMessageLine doc liNode line
        appendChild liNode ulNode
    )
    errorLines
  pure ulElement

createErrorParagraphsDiv :: String -> Effect HD.HTMLDivElement
createErrorParagraphsDiv errorMessage = do
  let errorLines = split (Pattern "<br>") errorMessage
  w <- window
  htmlDoc <- document w
  doc <- pure $ toDocument htmlDoc
  divRaw <- createElement "div" doc
  divEl <- maybe (throwMinsiError (HTMLElementNotFound "div")) pure (HD.fromElement divRaw)
  let divNode = E.toNode (HD.toElement divEl)
  _ <- traverse
    ( \line -> do
        pRaw <- createElement "p" doc
        pEl <- maybe (throwMinsiError (HTMLElementNotFound "p")) pure (HP.fromElement pRaw)
        let pNode = E.toNode (HP.toElement pEl)
        appendMessageLine doc pNode line
        appendChild pNode divNode
    )
    errorLines
  pure divEl

appendMessageLine :: Document -> Node -> String -> Effect Unit
appendMessageLine doc parentNode line =
  if isUrlLine line then do
    anchorRaw <- createElement "a" doc
    anchor <- maybe (throwMinsiError (HTMLElementNotFound "a")) pure (HA.fromElement anchorRaw)
    let anchorNode = HA.toNode anchor
    setHref line (HA.toHTMLHyperlinkElementUtils anchor)
    setTextContent line anchorNode
    appendChild anchorNode parentNode
  else
    setTextContent line parentNode

isUrlLine :: String -> Boolean
isUrlLine line =
  isJust (stripPrefix (Pattern "https://") line)
    || isJust (stripPrefix (Pattern "http://") line)

showMinsiBlockingErrorDialog :: String -> Effect Unit
showMinsiBlockingErrorDialog errorMessage = do
  divEl <- createErrorParagraphsDiv errorMessage
  setBlockingModalBody (HD.toHTMLElement divEl)
  showModal minsiBlockingModalId (Just 5000)
