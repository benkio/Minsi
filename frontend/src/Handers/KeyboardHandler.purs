module Handlers.KeyboardHandler where

import Prelude
import Components.Modal (showModal)
import Data.Maybe (maybe)
import Effect (Effect)
import Handers.ErrorHandlers (genericErrorsHandler)
import Handlers.AddSubtitleButtonHandler (addSubtitleButtonEventListener)
import Handlers.RemoveSubtitleButtonHandler (removeFirstSubtitleRow)
import Handlers.ApplyButtonHandler (applyButtonEventListener)
import Handlers.CutRangeHandler (rangeToNumberListener)
import Handlers.SubtitleTimeButtonsHandler (setSubtitleEndButtonEventListener, setSubtitleStartButtonEventListener)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTemplateElement as HTP
import Web.HTML.Window (document)
import Web.HTML.Event.EventTypes as EClick
import Web.HTML.HTMLMediaElement (currentTime, duration, play, pause, paused, setCurrentTime)
import Web.HTML.HTMLVideoElement (HTMLVideoElement, toHTMLMediaElement)
import Web.UIEvent.KeyboardEvent (KeyboardEvent, altKey, ctrlKey, key, metaKey, fromEvent, toEvent)
import Web.UIEvent.KeyboardEvent.EventTypes as E

data KeyboardHandlerTargets = KHT
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
  , cutStartValue :: HI.HTMLInputElement
  , cutEndValue :: HI.HTMLInputElement
  , subtitleTable :: HT.HTMLTableElement
  , subtitleRow :: HTP.HTMLTemplateElement
  , resultVideo :: HTMLVideoElement
  , keyboardShortcutsModalId :: String
  , keyboardShortcutsButton :: HB.HTMLButtonElement
  }

setKeyboardHandlers :: KeyboardHandlerTargets -> Effect Unit
setKeyboardHandlers targets = genericErrorsHandler $ do
  w <- window
  doc <- document w
  keyboardEvL <- eventListener (keyboardEventListener targets)
  addEventListener E.keydown keyboardEvL false (HTMLDocument.toEventTarget doc)
  shortcutsClickEvL <- eventListener \_ -> showShortcutsModal targets
  addEventListener EClick.click shortcutsClickEvL false (toEventTarget (HB.toElement (keyboardShortcutsButton targets)))
  where
  keyboardShortcutsButton (KHT { keyboardShortcutsButton: b }) = b
  showShortcutsModal (KHT { keyboardShortcutsModalId: id }) = showModal id

keyboardEventListener :: KeyboardHandlerTargets -> Event -> Effect Unit
keyboardEventListener targets ev = maybe (pure unit) (handleKeyboardEvent targets) (fromEvent ev)

handleKeyboardEvent :: KeyboardHandlerTargets -> KeyboardEvent -> Effect Unit
handleKeyboardEvent (KHT { cutStart, cutEnd, cutStartValue, cutEndValue, subtitleTable, subtitleRow, resultVideo, keyboardShortcutsModalId: shortcutsModalId }) keyboardEvent = do
  when (keyValue == "Enter" && (isCtrl || isMeta)) (applyButtonEventListener (toEvent keyboardEvent))
  when (keyValue == " " && isCtrl) (toggleResultVideoPlayback resultVideo)
  when (keyValue == "ArrowLeft") (skipResultVideoBackward resultVideo)
  when (keyValue == "ArrowRight") (skipResultVideoForward resultVideo)
  when (keyValue == "?" && isCtrl) (showModal shortcutsModalId)
  --TODO: to be tested
  when (keyValue == "s" && (isCtrl || isMeta)) (rangeToNumberListener cutStart cutStartValue (toEvent keyboardEvent))
  when (keyValue == "e" && (isCtrl || isMeta)) (rangeToNumberListener cutEnd cutEndValue (toEvent keyboardEvent))
  when (keyValue == "s" && isAlt) (setSubtitleStartButtonEventListener subtitleTable resultVideo (toEvent keyboardEvent))
  when (keyValue == "e" && isAlt) (setSubtitleEndButtonEventListener subtitleTable resultVideo (toEvent keyboardEvent))
  when (keyValue == "+" && isAlt) (addSubtitleButtonEventListener subtitleTable subtitleRow (toEvent keyboardEvent))
  when (keyValue == "-" && isAlt) (removeFirstSubtitleRow subtitleTable)
  where
  isCtrl = ctrlKey keyboardEvent
  isMeta = metaKey keyboardEvent
  isAlt = altKey keyboardEvent
  keyValue = key keyboardEvent

toggleResultVideoPlayback :: HTMLVideoElement -> Effect Unit
toggleResultVideoPlayback video = do
  let media = toHTMLMediaElement video
  isPaused <- paused media
  if isPaused then play media else pause media

skipSeconds :: Number
skipSeconds = 0.5

skipResultVideoBackward :: HTMLVideoElement -> Effect Unit
skipResultVideoBackward video = do
  let media = toHTMLMediaElement video
  t <- currentTime media
  setCurrentTime (max 0.0 (t - skipSeconds)) media

skipResultVideoForward :: HTMLVideoElement -> Effect Unit
skipResultVideoForward video = do
  let media = toHTMLMediaElement video
  t <- currentTime media
  d <- duration media
  setCurrentTime (min d (t + skipSeconds)) media
