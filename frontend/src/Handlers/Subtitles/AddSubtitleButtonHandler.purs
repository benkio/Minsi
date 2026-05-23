module Handlers.Subtitles.AddSubtitleButtonHandler where

import Prelude

import Components.HTMLTableElement (getFirstRow, getTBody)
import Components.HTMLTableRowElement (getTableCellValue, setTableCellValue)
import Components.HTMLTemplateElement (getRow)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_addSubtitleButton, _subtitleRowTemplate, _subtitleTable)
import Data.Either (either)
import Data.Lens (view)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Console (log)
import Effect.Exception (try)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.ResultMedia.MediaSrc (getMediaElement)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (addRemoveSubtitleListenerToRow)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.Element (fromNode, toEventTarget)
import Web.DOM.Node (appendChild, deepClone, insertBefore)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLMediaElement (HTMLMediaElement, currentTime)
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HTR
import Web.HTML.HTMLTableSectionElement as HTS
import Web.HTML.HTMLTemplateElement as HTP

setAddSubtitleButtonHandler :: Effect Unit
setAddSubtitleButtonHandler = genericErrorsHandler $ do
  components <- loadComponents
  let
    addSubtitleButton = view _addSubtitleButton components
    subtitleTable = view _subtitleTable components
    subtitleRowTemplate = view _subtitleRowTemplate components
    addSubtitleButtonEventTarget = toEventTarget (HB.toElement addSubtitleButton)
  log "Setting up add subtitle button handler"
  addSubtitleButtonEvL <- eventListener (addSubtitleButtonEventListener subtitleTable subtitleRowTemplate)
  addEventListener E.click addSubtitleButtonEvL false addSubtitleButtonEventTarget
  log "✅ ➕ subtitle button handler set up"

addSubtitleButtonEventListener :: HT.HTMLTableElement -> HTP.HTMLTemplateElement -> Event -> Effect Unit
addSubtitleButtonEventListener subtitleTable subtitleRowTemplate _ = genericErrorsHandler $ do
  log "🏁 ➕ Subtitle Button"
  components <- loadComponents
  media <- getMediaElement components
  eitherFirstRow <- try $ getFirstRow subtitleTable
  either
    (const $ addNewRow subtitleTable subtitleRowTemplate)
    (\firstRow -> cloneFirstRow firstRow subtitleTable media)
    eitherFirstRow
  log "✅ ➕ Subtitle Button"

addNewRow :: HT.HTMLTableElement -> HTP.HTMLTemplateElement -> Effect Unit
addNewRow subtitleTable subtitleRowTemplate = do
  subtitleRow <- getRow subtitleRowTemplate
  tbody <- getTBody subtitleTable
  clonedRowNode <- deepClone (HTR.toNode subtitleRow)
  clonedRow <- maybe (throwMinsiError (HTMLElementNotFound "subtitleRow")) pure (fromNode clonedRowNode >>= HTR.fromElement)
  appendChild clonedRowNode (HTS.toNode tbody)
  addRemoveSubtitleListenerToRow clonedRow
  log "✅ Subtitle row added"

cloneFirstRow :: HTR.HTMLTableRowElement -> HT.HTMLTableElement -> HTMLMediaElement -> Effect Unit
cloneFirstRow firstRow subtitleTable media = do
  log "🏁 Subtitle row clone - Clone Row"
  tbody <- getTBody subtitleTable
  clonedRowNode <- deepClone (HTR.toNode firstRow)
  clonedRow <- maybe (throwMinsiError (HTMLElementNotFound "ClonedRow")) pure (fromNode clonedRowNode >>= HTR.fromElement)
  log "Subtitle row clone - get current media value (ms)"
  endSeconds <- currentTime media
  let endValueMs = endSeconds * 1000.0
  log $ "Subtitle row clone - Set End Last row to " <> show endValueMs
  setTableCellValue "End" (show endValueMs) firstRow
  let newStartValue = show $ endValueMs + 100.0
  log $ "Subtitle row clone - Set new row to start to " <> newStartValue
  setTableCellValue "Start" newStartValue clonedRow
  fontColor <- getTableCellValue "FontColor" firstRow
  log $ "Subtitle row clone - Set new row to Font/Color to " <> fontColor
  setTableCellValue "FontColor" fontColor clonedRow
  size <- getTableCellValue "Size" firstRow
  log $ "Subtitle row clone - Set new row size to " <> size
  setTableCellValue "Size" size clonedRow
  position <- getTableCellValue "Position" firstRow
  log $ "Subtitle row clone - Set new row font position to " <> position
  setTableCellValue "Position" position clonedRow
  log "Insert the new row"
  insertBefore clonedRowNode (HTR.toNode firstRow) (HTS.toNode tbody)
  log "Add remove event listeren to new row"
  addRemoveSubtitleListenerToRow clonedRow
  log "✅ Subtitle row cloned"
