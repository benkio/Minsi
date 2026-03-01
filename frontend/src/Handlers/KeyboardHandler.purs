module Handlers.KeyboardHandler where

import Prelude

import Components.Modal (showModal)
import Data.Maybe (maybe, isJust)
import Effect (Effect)
import Handlers.ApplyButtonHandler (applyButtonEventListener)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.Subtitles.AddSubtitleButtonHandler (addSubtitleButtonEventListener)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (removeFirstSubtitleRow)
import Web.DOM.Element (fromEventTarget, toEventTarget)
import Web.Event.Event (preventDefault, target)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as EClick
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLMediaElement (currentTime, duration, play, pause, paused, setCurrentTime)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTemplateElement as HTP
import Web.HTML.HTMLTextAreaElement as HTA
import Web.HTML.HTMLVideoElement (HTMLVideoElement, toHTMLMediaElement)
import Web.HTML.Window (document)
import Web.UIEvent.KeyboardEvent (KeyboardEvent, ctrlKey, key, metaKey, fromEvent, toEvent)
import Web.UIEvent.KeyboardEvent.EventTypes as E

data KeyboardHandlerTargets = KHT
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
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
  showShortcutsModal (KHT { keyboardShortcutsModalId: id }) = showModal id true

keyboardEventListener :: KeyboardHandlerTargets -> Event -> Effect Unit
keyboardEventListener targets ev = genericErrorsHandler $ maybe (pure unit) (handleKeyboardEvent targets) (fromEvent ev)

-- True when the keydown target is an input, textarea, or select (so we don't steal arrow/space from typing).
isTargetEditableElement :: KeyboardEvent -> Boolean
isTargetEditableElement ke =
  maybe false
    (\el -> isJust (HI.fromElement el) || isJust (HTA.fromElement el) || isJust (HS.fromElement el))
    (target (toEvent ke) >>= fromEventTarget)

handleKeyboardEvent :: KeyboardHandlerTargets -> KeyboardEvent -> Effect Unit
handleKeyboardEvent (KHT { resultVideo, keyboardShortcutsModalId, subtitleTable, subtitleRow }) keyboardEvent = genericErrorsHandler $ do
  let ev = toEvent keyboardEvent
  let stop = preventDefault ev
  let whenNotEditable cond act = when (cond && not (isTargetEditableElement keyboardEvent)) (act *> stop)
  when (keyValue == "Enter" && (isCtrl || isMeta)) (applyButtonEventListener ev *> stop)
  when (keyValue == "+") (addSubtitleButtonEventListener subtitleTable subtitleRow (toEvent keyboardEvent) *> stop)
  when (keyValue == "-") (removeFirstSubtitleRow subtitleTable *> stop)
  whenNotEditable (keyValue == " ") (toggleResultVideoPlayback resultVideo)
  whenNotEditable (keyValue == "ArrowLeft") (skipResultVideoBackward resultVideo)
  whenNotEditable (keyValue == "ArrowRight") (skipResultVideoForward resultVideo)
  whenNotEditable (keyValue == "?") (showModal keyboardShortcutsModalId true *> stop)
  where
  isCtrl = ctrlKey keyboardEvent
  isMeta = metaKey keyboardEvent
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
