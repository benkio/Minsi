module Handlers.CopyTranscriptButtonHandler where

import Prelude

import Conversion.String (capitalize)
import Data.Array (sort)
import Data.Newtype (unwrap)
import Data.String (joinWith)
import Data.String.Common (toLower)
import Data.Tuple (fst)
import Effect (Effect)
import Model.State.State (Subtitle(..))
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.Window (promptDefault)

setCopyTranscriptButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setCopyTranscriptButtonHandler copyTranscriptButton = do
  evL <- eventListener (copyTranscriptButtonEventListener)
  addEventListener E.click evL false (toEventTarget (HB.toElement copyTranscriptButton))

copyTranscriptButtonEventListener :: Event -> Effect Unit
copyTranscriptButtonEventListener _ = do
  state <- getCurrentState
  let
    subtitles = (unwrap (fst state)).subtitles
    transcript = capitalize <<< joinWith " " $ (\(Subtitle { value }) -> toLower value) <$> sort subtitles
  w <- window
  void $ promptDefault "Copy to clipboard: Ctrl+C, Enter" transcript w
