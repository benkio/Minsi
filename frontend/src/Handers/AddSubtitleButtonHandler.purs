module Handlers.AddSubtitleButtonHandler where
import Prelude

import Web.DOM.Node(deepClone, insertBefore)
import Effect (Effect)
import Effect.Console (log)
import Web.DOM.Element (toEventTarget, fromNode)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLTableElement as HT
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Data.Maybe (maybe)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLTableSectionElement as HTS
import Web.HTML.HTMLTableRowElement as HTR
import Web.HTML.HTMLInputElement (valueAsNumber, setValue)
import Handers.ErrorHandlers (genericErrorsHandler)
import Components.HTMLTableElement (getFirstRow, getTBody, getStartInput, getEndInput)

setAddSubtitleButtonHandler :: HB.HTMLButtonElement -> HT.HTMLTableElement -> Effect Unit
setAddSubtitleButtonHandler addSubtitleButton subtitleTable = do
  log "Setting up add subtitle button handler"
  addSubtitleButtonEvL <- eventListener (addSubtitleButtonEventListener subtitleTable)
  addEventListener E.click addSubtitleButtonEvL false addSubtitleButtonEventTarget
  log "Add subtitle button handler set up successfully"
  where
  addSubtitleButtonEventTarget = toEventTarget (HB.toElement addSubtitleButton)

addSubtitleButtonEventListener :: HT.HTMLTableElement -> Event -> Effect Unit
addSubtitleButtonEventListener subtitleTable _ = genericErrorsHandler $ do
  log "Add subtitle button clicked"
  tbody <- getTBody subtitleTable
  firstRow <- getFirstRow subtitleTable
  clonedRowNode <- deepClone (HTR.toNode firstRow)
  clonedRow <- maybe (throwMinsiError (HTMLElementNotFound "ClonedRow")) pure (fromNode clonedRowNode >>= HTR.fromElement)

  -- Get start value from the first row
  firstRowEndInput <- getEndInput firstRow
  endValue <- valueAsNumber firstRowEndInput

  -- Set cloned row end time = start time of first row
  clonedRowStartInput <- getStartInput clonedRow
  setValue (show endValue) clonedRowStartInput

  -- Set cloned row start time = start time - 1000 (1 second before)
  let newEndValue = endValue + 1000.0
  clonedRowEndInput <- getEndInput clonedRow
  setValue (show newEndValue) clonedRowEndInput

  -- Insert the cloned row before the first row
  insertBefore clonedRowNode (HTR.toNode firstRow) (HTS.toNode tbody)
  log "Subtitle row cloned successfully"
