module Handlers.CopyTranscriptButtonHandler where

import Prelude

import Conversion.String (capitalizeFirst)
import Data.Array (sort)
import Data.String (joinWith)
import Data.String.Common (toLower, trim)
import Data.Tuple (fst)
import Effect (Effect)
import Model.State.State (Subtitle(..))
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_copyTranscriptButton, _genericModalContent)
import Components.HtmlIdAndClasses (genericModalId)
import Components.Modal (showModal)
import Data.Lens (view)
import Model.State.Lenses (_subtitles)
import Model.State.StateFromHtml (getCurrentState)
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
copyTranscriptButtonEventListener _ = do
  components <- loadComponents
  state <- getCurrentState
  let
    subtitles = view _subtitles (fst state)
    transcript = capitalizeFirst <<< joinWith " " $ (\(Subtitle { value }) -> (toLower <<< trim) value) <$> sort subtitles
    genericModalContentEl = view _genericModalContent components
  setTextContent transcript (HP.toNode genericModalContentEl)
  showModal genericModalId true
