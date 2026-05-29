module Handlers.KeyboardHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_keyboardShortcutsButton, _subtitleRowTemplate, _subtitleTable)
import Components.HtmlIdAndClasses (keyboardShortcutsModalId)
import Components.Modal (showModal)
import Data.Lens (view)
import Data.Maybe (Maybe(..), maybe, isJust)
import Effect (Effect)
import Handlers.ApplyButtonHandler (applyButtonEventListener)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultMedia.MediaSrc (getMediaElement)
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
import Web.HTML.HTMLMediaElement (HTMLMediaElement, currentTime, duration, play, pause, paused, setCurrentTime)
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTextAreaElement as HTA
import Web.HTML.Window (document)
import Web.UIEvent.KeyboardEvent (KeyboardEvent, ctrlKey, key, metaKey, fromEvent, toEvent)
import Web.UIEvent.KeyboardEvent.EventTypes as E

setKeyboardHandlers :: Effect Unit
setKeyboardHandlers = genericErrorsHandler $ do
  setKeyboardHandler
  setKeyboardShortcutsButtonHandler

setKeyboardHandler :: Effect Unit
setKeyboardHandler = do
  w <- window
  doc <- document w
  keyboardEvL <- eventListener keyboardEventListener
  addEventListener E.keydown keyboardEvL false (HTMLDocument.toEventTarget doc)

setKeyboardShortcutsButtonHandler :: Effect Unit
setKeyboardShortcutsButtonHandler = do
  components <- loadComponents
  let keyboardShortcutsButton = view _keyboardShortcutsButton components
  shortcutsClickEvL <- eventListener \_ -> showModal keyboardShortcutsModalId (Just 10000)
  addEventListener EClick.click shortcutsClickEvL false (toEventTarget (HB.toElement keyboardShortcutsButton))

keyboardEventListener :: Event -> Effect Unit
keyboardEventListener ev = genericErrorsHandler $ maybe (pure unit) handleKeyboardEvent (fromEvent ev)

-- True when the keydown target is an input, textarea, or select (so we don't steal arrow/space from typing).
isTargetEditableElement :: KeyboardEvent -> Boolean
isTargetEditableElement ke =
  maybe false
    (\el -> isJust (HI.fromElement el) || isJust (HTA.fromElement el) || isJust (HS.fromElement el))
    (target (toEvent ke) >>= fromEventTarget)

handleKeyboardEvent :: KeyboardEvent -> Effect Unit
handleKeyboardEvent keyboardEvent = genericErrorsHandler $ do
  components <- loadComponents
  let
    subtitleTable = view _subtitleTable components
    subtitleRow = view _subtitleRowTemplate components
    ev = toEvent keyboardEvent
    stop = preventDefault ev
    whenNotEditable cond act = when (cond && not (isTargetEditableElement keyboardEvent)) (act *> stop)
    isCtrl = ctrlKey keyboardEvent
    isMeta = metaKey keyboardEvent
    keyValue = key keyboardEvent
  media <- getMediaElement components
  when (keyValue == "Enter" && (isCtrl || isMeta)) (applyButtonEventListener ev *> stop)
  when (keyValue == "+") (addSubtitleButtonEventListener subtitleTable subtitleRow (toEvent keyboardEvent) *> stop)
  when (keyValue == "-") (removeFirstSubtitleRow subtitleTable *> stop)
  whenNotEditable (keyValue == " ") (toggleResultMediaPlayback media)
  whenNotEditable (keyValue == "ArrowLeft") (skipResultMediaBackward media)
  whenNotEditable (keyValue == "ArrowRight") (skipResultMediaForward media)
  whenNotEditable (keyValue == "?") (showModal keyboardShortcutsModalId (Just 10000) *> stop)

toggleResultMediaPlayback :: HTMLMediaElement -> Effect Unit
toggleResultMediaPlayback media = do
  isPaused <- paused media
  if isPaused then play media else pause media

skipSeconds :: Number
skipSeconds = 0.5

skipResultMediaBackward :: HTMLMediaElement -> Effect Unit
skipResultMediaBackward media = do
  t <- currentTime media
  setCurrentTime (max 0.0 (t - skipSeconds)) media

skipResultMediaForward :: HTMLMediaElement -> Effect Unit
skipResultMediaForward media = do
  t <- currentTime media
  d <- duration media
  setCurrentTime (min d (t + skipSeconds)) media
