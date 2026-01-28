module Handlers.SubtitleTimeButtonsHandler where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLVideoElement (HTMLVideoElement, toHTMLMediaElement)
import Web.HTML.HTMLMediaElement (currentTime)
import Web.HTML.HTMLInputElement (setValue)
import Web.HTML.Event.EventTypes as E
import Handers.ErrorHandlers (genericErrorsHandler)
import Components.HTMLTableElement (getFirstRow, getStartInput, getEndInput)

data SubtitleTimeButtonsTargets = STBT
  { setSubtitleStartButton :: HB.HTMLButtonElement
  , setSubtitleEndButton :: HB.HTMLButtonElement
  , subtitleTable :: HT.HTMLTableElement
  , resultVideo :: HTMLVideoElement
  }

setSubtitleTimeButtonsHandlers :: SubtitleTimeButtonsTargets -> Effect Unit
setSubtitleTimeButtonsHandlers (STBT { setSubtitleStartButton, setSubtitleEndButton, subtitleTable, resultVideo }) = do
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
