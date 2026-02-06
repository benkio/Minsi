module Handlers.Subtitles.AddSubtitleButtonHandler where

import Prelude

import Components.HTMLTableElement (getFirstRow, getStartInput, getTBody)
import Components.HTMLTableRowElement (getEndInput)
import Data.Either (Either(..))
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Console (log)
import Effect.Exception (try)
import Handlers.ApplyButtonHandler (getRow)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (addRemoveSubtitleListenerToRow)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Web.DOM.Element (fromNode, toEventTarget)
import Web.DOM.Node (appendChild, deepClone, insertBefore)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement (setValue, valueAsNumber)
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HTR
import Web.HTML.HTMLTableSectionElement as HTS
import Web.HTML.HTMLTemplateElement as HTP

setAddSubtitleButtonHandler :: HB.HTMLButtonElement -> HT.HTMLTableElement -> HTP.HTMLTemplateElement -> Effect Unit
setAddSubtitleButtonHandler addSubtitleButton subtitleTable subtitleRowTemplate = genericErrorsHandler $ do
  log "Setting up add subtitle button handler"
  addSubtitleButtonEvL <- eventListener (addSubtitleButtonEventListener subtitleTable subtitleRowTemplate)
  addEventListener E.click addSubtitleButtonEvL false addSubtitleButtonEventTarget
  log "Add subtitle button handler set up successfully"
  where
  addSubtitleButtonEventTarget = toEventTarget (HB.toElement addSubtitleButton)

addSubtitleButtonEventListener :: HT.HTMLTableElement -> HTP.HTMLTemplateElement -> Event -> Effect Unit
addSubtitleButtonEventListener subtitleTable subtitleRowTemplate _ = genericErrorsHandler $ do
  log "Add subtitle button clicked"
  eitherFirstRow <- try $ getFirstRow subtitleTable
  case eitherFirstRow of
    Left _ -> addNewRow subtitleTable subtitleRowTemplate
    Right firstRow -> cloneFirstRow firstRow subtitleTable

addNewRow :: HT.HTMLTableElement -> HTP.HTMLTemplateElement -> Effect Unit
addNewRow subtitleTable subtitleRowTemplate = do
  subtitleRow <- getRow subtitleRowTemplate
  tbody <- getTBody subtitleTable
  clonedRowNode <- deepClone (HTR.toNode subtitleRow)
  clonedRow <- maybe (throwMinsiError (HTMLElementNotFound "subtitleRow")) pure (fromNode clonedRowNode >>= HTR.fromElement)
  appendChild clonedRowNode (HTS.toNode tbody)
  addRemoveSubtitleListenerToRow clonedRow
  log "Subtitle row added successfully"

cloneFirstRow :: HTR.HTMLTableRowElement -> HT.HTMLTableElement -> Effect Unit
cloneFirstRow firstRow subtitleTable = do
  tbody <- getTBody subtitleTable
  clonedRowNode <- deepClone (HTR.toNode firstRow)
  clonedRow <- maybe (throwMinsiError (HTMLElementNotFound "ClonedRow")) pure (fromNode clonedRowNode >>= HTR.fromElement)
  firstRowEndInput <- getEndInput firstRow
  endValue <- valueAsNumber firstRowEndInput
  clonedRowStartInput <- getStartInput clonedRow
  setValue (show endValue) clonedRowStartInput
  let newEndValue = endValue + 1.0
  clonedRowEndInput <- getEndInput clonedRow
  setValue (show newEndValue) clonedRowEndInput
  insertBefore clonedRowNode (HTR.toNode firstRow) (HTS.toNode tbody)
  addRemoveSubtitleListenerToRow clonedRow
  log "Subtitle row cloned successfully"
