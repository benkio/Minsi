module Handlers.Subtitles.SubtitleTimeButtonsHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_resultVideo, _setSubtitleEndButton, _setSubtitleStartButton, _subtitleTable)
import Components.HTMLTableElement (getFirstRow, getStartInput)
import Components.HTMLTableRowElement (getEndInput)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement (setValue)
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLVideoElement (HTMLVideoElement, toHTMLMediaElement)
import Web.HTML.HTMLMediaElement (currentTime)

setSubtitleTimeButtonsHandlers :: Effect Unit
setSubtitleTimeButtonsHandlers = genericErrorsHandler $ do
  components <- loadComponents
  let
    setSubtitleStartButton = view _setSubtitleStartButton components
    setSubtitleEndButton = view _setSubtitleEndButton components
    subtitleTable = view _subtitleTable components
    resultVideo = view _resultVideo components
  startButtonEvL <- eventListener (setSubtitleStartButtonEventListener subtitleTable resultVideo)
  endButtonEvL <- eventListener (setSubtitleEndButtonEventListener subtitleTable resultVideo)
  addEventListener E.click startButtonEvL false (toEventTarget (HB.toElement setSubtitleStartButton))
  addEventListener E.click endButtonEvL false (toEventTarget (HB.toElement setSubtitleEndButton))
  log "Subtitle time buttons handlers set up successfully"

setSubtitleStartButtonEventListener :: HT.HTMLTableElement -> HTMLVideoElement -> Event -> Effect Unit
setSubtitleStartButtonEventListener subtitleTable resultVideo _ = genericErrorsHandler $ do
  log "Set subtitle start button clicked"
  currentTimeValue <- currentTime (toHTMLMediaElement resultVideo)
  firstRow <- getFirstRow subtitleTable
  startInput <- getStartInput firstRow
  setValue (show (currentTimeValue * 1000.0)) startInput
  log "Subtitle start time set successfully"

setSubtitleEndButtonEventListener :: HT.HTMLTableElement -> HTMLVideoElement -> Event -> Effect Unit
setSubtitleEndButtonEventListener subtitleTable resultVideo _ = genericErrorsHandler $ do
  log "Set subtitle end button clicked"
  currentTimeValue <- currentTime (toHTMLMediaElement resultVideo)
  firstRow <- getFirstRow subtitleTable
  endInput <- getEndInput firstRow
  setValue (show (currentTimeValue * 1000.0)) endInput
  log "Subtitle end time set successfully"
