module Handlers.RemoveSubtitleButtonHandler where

import Prelude
import Components.HTMLTableElement (getRows)
import Data.Foldable (traverse_)
import Effect (Effect)
import Effect.Console (log)
import Handers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HR

setRemoveSubtitleButtonHandler :: HT.HTMLTableElement -> Effect Unit
setRemoveSubtitleButtonHandler subtitleTable = do
  log "Setting up remove subtitle button handlers"
  rows <- getRows subtitleTable
  traverse_ (\r ->
               removeEventListener r >>= \evl ->
               addEventListener E.click evl false (tableRowEventTarget r)) rows
  log "Remove subtitle button handler set up successfully"
  where
    tableRowEventTarget r = toEventTarget (HR.toElement r)
    removeEventListener r = eventListener (removeSubtitleButtonEventListener r)

removeSubtitleButtonEventListener :: HR.HTMLTableRowElement -> Event -> Effect Unit
removeSubtitleButtonEventListener _subtitleTableRow _ev = genericErrorsHandler $ do
  pure unit
  --TODO: implement
  -- log "Remove subtitle button clicked"
  -- tbody <- getTBody subtitleTable
  -- firstRow <- getFirstRow subtitleTable
  -- clonedRowNode <- deepClone (HTR.toNode firstRow)
  -- clonedRow <- maybe (throwMinsiError (HTMLElementNotFound "ClonedRow")) pure (fromNode clonedRowNode >>= HTR.fromElement)

  -- -- Get start value from the first row
  -- firstRowEndInput <- getEndInput firstRow
  -- endValue <- valueAsNumber firstRowEndInput

  -- -- Set cloned row end time = start time of first row
  -- clonedRowStartInput <- getStartInput clonedRow
  -- setValue (show endValue) clonedRowStartInput

  -- -- Set cloned row start time = start time - 1000 (1 second before)
  -- let newEndValue = endValue + 1000.0
  -- clonedRowEndInput <- getEndInput clonedRow
  -- setValue (show newEndValue) clonedRowEndInput

  -- -- Insert the cloned row before the first row
  -- insertBefore clonedRowNode (HTR.toNode firstRow) (HTS.toNode tbody)
  -- log "Subtitle row cloned successfully"
