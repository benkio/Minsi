module Handlers.Subtitles.AddSubtitleButtonHandler where

import Prelude

import Components.HTMLTableElement (getFirstRow, getStartInput, getTBody)
import Components.HTMLTableRowElement (getEndInput, setEndInput)
import Components.HTMLTemplateElement (getRow)
import Data.Either (either)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Console (log)
import Effect.Exception (try)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_addSubtitleButton, _resultVideo, _subtitleRowTemplate, _subtitleTable)
import Data.Lens (view)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.Subtitles.RemoveSubtitleButtonHandler (addRemoveSubtitleListenerToRow)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.Element (fromNode, toEventTarget)
import Web.DOM.Node (appendChild, deepClone, insertBefore)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement (setValue)
import Web.HTML.HTMLMediaElement (currentTime)
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HTR
import Web.HTML.HTMLTableSectionElement as HTS
import Web.HTML.HTMLTemplateElement as HTP
import Web.HTML.HTMLVideoElement as HV

setAddSubtitleButtonHandler :: Effect Unit
setAddSubtitleButtonHandler = genericErrorsHandler $ do
  components <- loadComponents
  let
    addSubtitleButton = view _addSubtitleButton components
    subtitleTable = view _subtitleTable components
    subtitleRowTemplate = view _subtitleRowTemplate components
    resultVideo = view _resultVideo components
    addSubtitleButtonEventTarget = toEventTarget (HB.toElement addSubtitleButton)
  log "Setting up add subtitle button handler"
  addSubtitleButtonEvL <- eventListener (addSubtitleButtonEventListener subtitleTable subtitleRowTemplate resultVideo)
  addEventListener E.click addSubtitleButtonEvL false addSubtitleButtonEventTarget
  log "Add subtitle button handler set up successfully"

addSubtitleButtonEventListener :: HT.HTMLTableElement -> HTP.HTMLTemplateElement -> HV.HTMLVideoElement -> Event -> Effect Unit
addSubtitleButtonEventListener subtitleTable subtitleRowTemplate resultVideo _ = genericErrorsHandler $ do
  log "Add subtitle button clicked"
  eitherFirstRow <- try $ getFirstRow subtitleTable
  either
    (const $ addNewRow subtitleTable subtitleRowTemplate)
    (\firstRow -> cloneFirstRow firstRow subtitleTable resultVideo)
    eitherFirstRow

addNewRow :: HT.HTMLTableElement -> HTP.HTMLTemplateElement -> Effect Unit
addNewRow subtitleTable subtitleRowTemplate = do
  subtitleRow <- getRow subtitleRowTemplate
  tbody <- getTBody subtitleTable
  clonedRowNode <- deepClone (HTR.toNode subtitleRow)
  clonedRow <- maybe (throwMinsiError (HTMLElementNotFound "subtitleRow")) pure (fromNode clonedRowNode >>= HTR.fromElement)
  appendChild clonedRowNode (HTS.toNode tbody)
  addRemoveSubtitleListenerToRow clonedRow
  log "Subtitle row added successfully"

cloneFirstRow :: HTR.HTMLTableRowElement -> HT.HTMLTableElement -> HV.HTMLVideoElement -> Effect Unit
cloneFirstRow firstRow subtitleTable resultVideo = do
  tbody <- getTBody subtitleTable
  clonedRowNode <- deepClone (HTR.toNode firstRow)
  endValueSeconds <- currentTime (HV.toHTMLMediaElement resultVideo)
  let endValue = endValueSeconds * 1000.0
  clonedRow <- maybe (throwMinsiError (HTMLElementNotFound "ClonedRow")) pure (fromNode clonedRowNode >>= HTR.fromElement)
  setEndInput endValue firstRow
  clonedRowStartInput <- getStartInput clonedRow
  setValue (show (endValue + 100.0)) clonedRowStartInput
  let newEndValue = endValue + 201.0
  clonedRowEndInput <- getEndInput clonedRow
  setValue (show newEndValue) clonedRowEndInput
  insertBefore clonedRowNode (HTR.toNode firstRow) (HTS.toNode tbody)
  addRemoveSubtitleListenerToRow clonedRow
  log "Subtitle row cloned successfully"
