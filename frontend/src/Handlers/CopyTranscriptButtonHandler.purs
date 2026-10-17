module Handlers.CopyTranscriptButtonHandler where

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_clipboardOutputModalContent, _copyTranscriptButton)
import Components.HtmlIdAndClasses (clipboardOutputModalId)
import Components.Modal (showModal)
import Data.Lens (view)
import Data.Maybe (Maybe(..))
import Data.Tuple (fst)
import Effect (Effect)
import Effect.Aff (Aff, runAff_)
import Effect.Class (liftEffect)
import Endpoints.Transcript (callTranscript)
import Handlers.ClipboardOutputModalCopyClipboardButtonHandler (copyModalContentToClipboardAff)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (State(..))
import Model.State.StateFromHtml (getCurrentState)
import Prelude
import Web.Clipboard (Clipboard, clipboard)
import Web.DOM.Element (toEventTarget)
import Web.DOM.Node (setTextContent)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLPreElement as HP
import Web.HTML.Window (navigator)

setCopyTranscriptButtonHandler :: Effect Unit
setCopyTranscriptButtonHandler = do
  components <- loadComponents
  let copyTranscriptButton = view _copyTranscriptButton components
  evL <- eventListener (copyTranscriptButtonEventListener)
  addEventListener E.click evL false (toEventTarget (HB.toElement copyTranscriptButton))

copyTranscriptButtonEventListener :: Event -> Effect Unit
copyTranscriptButtonEventListener _ = genericErrorsHandler $ do
  stateTuple <- getCurrentState
  components <- loadComponents
  let
    copyTranscriptButton = view _copyTranscriptButton components
    requestedFilename = case fst stateTuple of
      State { filename } -> filename
  HB.setDisabled true copyTranscriptButton
  runAff_
    ( \result -> do
        HB.setDisabled false copyTranscriptButton
        genericErrorsHandlerEither result
    )
    (copyTranscriptFromBackendAff requestedFilename)

copyTranscriptFromBackendAff :: String -> Aff Unit
copyTranscriptFromBackendAff requestedFilename = do
  { markdown } <- callTranscript requestedFilename
  currentStateTuple <- liftEffect getCurrentState
  let currentFilename = case fst currentStateTuple of
        State { filename } -> filename
  when (isStaleTranscriptRequest requestedFilename currentFilename) $
    liftEffect $ throwMinsiError (InvalidInput "copyTranscriptButton" "Selected transcript changed while copying. Please retry.")
  cb <- liftEffect getClipboardOrThrow
  copyModalContentToClipboardAff cb markdown
  liftEffect do
    components <- loadComponents
    let clipboardContentEl = view _clipboardOutputModalContent components
    setTextContent markdown (HP.toNode clipboardContentEl)
    showModal clipboardOutputModalId (Just 5000)

getClipboardOrThrow :: Effect Clipboard
getClipboardOrThrow = do
  w <- window
  nav <- navigator w
  maybeClip <- clipboard nav
  case maybeClip of
    Just cb -> pure cb
    Nothing ->
      throwMinsiError
        (ClipboardUnavailable "The Clipboard API is not available (unsupported browser or non-secure context).")

isStaleTranscriptRequest :: String -> String -> Boolean
isStaleTranscriptRequest requestedFilename currentFilename = requestedFilename /= currentFilename
