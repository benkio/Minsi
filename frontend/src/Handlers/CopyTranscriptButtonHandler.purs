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
import Components.HtmlComponents.Lenses (_copyTranscriptButton)
import Data.Lens (view)
import Model.State.Lenses (_subtitles)
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.Window (promptDefault)

setCopyTranscriptButtonHandler :: Effect Unit
setCopyTranscriptButtonHandler = do
  components <- loadComponents
  let copyTranscriptButton = view _copyTranscriptButton components
  evL <- eventListener (copyTranscriptButtonEventListener)
  addEventListener E.click evL false (toEventTarget (HB.toElement copyTranscriptButton))

copyTranscriptButtonEventListener :: Event -> Effect Unit
copyTranscriptButtonEventListener _ = do
  state <- getCurrentState
  let
    subtitles = view _subtitles (fst state)
    transcript = capitalizeFirst <<< joinWith " " $ (\(Subtitle { value }) -> (toLower <<< trim) value) <$> sort subtitles
  w <- window
  void $ promptDefault "Copy to clipboard: Ctrl+C, Enter" transcript w
