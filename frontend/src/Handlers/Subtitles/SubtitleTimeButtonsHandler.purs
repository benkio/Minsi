module Handlers.Subtitles.SubtitleTimeButtonsHandler where

import Prelude

import Components.HTMLTableElement (getFirstRow, getStartInput)
import Components.HTMLTableRowElement (getEndInput)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_setSubtitleEndButton, _setSubtitleStartButton, _subtitleTable)
import Data.Lens (view)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultMedia.MediaSrc (getMediaElement)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement (setValue)
import Web.HTML.HTMLMediaElement (currentTime)
import Web.HTML.HTMLTableElement as HT

setSubtitleTimeButtonsHandlers :: Effect Unit
setSubtitleTimeButtonsHandlers = genericErrorsHandler $ do
  components <- loadComponents
  let
    setSubtitleStartButton = view _setSubtitleStartButton components
    setSubtitleEndButton = view _setSubtitleEndButton components
    subtitleTable = view _subtitleTable components
  startButtonEvL <- eventListener (setSubtitleStartButtonEventListener subtitleTable)
  endButtonEvL <- eventListener (setSubtitleEndButtonEventListener subtitleTable)
  addEventListener E.click startButtonEvL false (toEventTarget (HB.toElement setSubtitleStartButton))
  addEventListener E.click endButtonEvL false (toEventTarget (HB.toElement setSubtitleEndButton))
  log "Subtitle time buttons handlers set up successfully"

setSubtitleStartButtonEventListener :: HT.HTMLTableElement -> Event -> Effect Unit
setSubtitleStartButtonEventListener subtitleTable _ = genericErrorsHandler $ do
  log "Set subtitle start button clicked"
  components <- loadComponents
  media <- getMediaElement components
  currentTimeValue <- currentTime media
  let currentTimeValueString = show (currentTimeValue * 1000.0)
  log $ "media current time: " <> show currentTimeValueString
  firstRow <- getFirstRow subtitleTable
  startInput <- getStartInput firstRow
  setValue currentTimeValueString startInput
  log "Subtitle start time set successfully"

setSubtitleEndButtonEventListener :: HT.HTMLTableElement -> Event -> Effect Unit
setSubtitleEndButtonEventListener subtitleTable _ = genericErrorsHandler $ do
  log "Set subtitle end button clicked"
  components <- loadComponents
  media <- getMediaElement components
  currentTimeValue <- currentTime media
  let currentTimeValueString = show (currentTimeValue * 1000.0)
  log $ "media current time: " <> show currentTimeValueString
  firstRow <- getFirstRow subtitleTable
  endInput <- getEndInput firstRow
  setValue currentTimeValueString endInput
  log "Subtitle end time set successfully"
