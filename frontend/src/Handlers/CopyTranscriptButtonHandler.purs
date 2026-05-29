module Handlers.CopyTranscriptButtonHandler where

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_clipboardOutputModalContent, _copyTranscriptButton)
import Components.HtmlIdAndClasses (clipboardOutputModalId)
import Components.Modal (showModal)
import Data.Lens (view)
import Data.Maybe (Maybe(..))
import Data.Tuple (fst)
import Effect (Effect)

import Handlers.ErrorHandlers (genericErrorsHandler)
import Model.State.Lenses (_subtitles)
import Model.State.State (subtitlesToString)
import Model.State.StateFromHtml (getCurrentState)
import Prelude
import Web.DOM.Element (toEventTarget)
import Web.DOM.Node (setTextContent)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLPreElement as HP

setCopyTranscriptButtonHandler :: Effect Unit
setCopyTranscriptButtonHandler = do
  components <- loadComponents
  let copyTranscriptButton = view _copyTranscriptButton components
  evL <- eventListener (copyTranscriptButtonEventListener)
  addEventListener E.click evL false (toEventTarget (HB.toElement copyTranscriptButton))

copyTranscriptButtonEventListener :: Event -> Effect Unit
copyTranscriptButtonEventListener _ = genericErrorsHandler $ do
  components <- loadComponents
  state <- getCurrentState
  let
    subtitles = view _subtitles (fst state)
    transcript = subtitlesToString subtitles
    clipboardContentEl = view _clipboardOutputModalContent components
  setTextContent transcript (HP.toNode clipboardContentEl)
  showModal clipboardOutputModalId (Just 5000)
