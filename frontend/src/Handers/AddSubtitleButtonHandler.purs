module Handlers.AddSubtitleButtonHandler where
import Prelude

import Web.DOM.Node(deepClone, appendChild)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Web.DOM.HTMLCollection as HC
import Effect (Effect)
import Effect.Console (log)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLTableElement as HT
import Web.DOM.Element as HE
import Web.HTML.Event.EventTypes as E
import Data.Array (head, last)
import Web.HTML.HTMLTableSectionElement as HTS
import Data.Maybe (maybe)
import Handers.ErrorHandlers (genericErrorsHandler)

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
  tbody <- HT.tBodies subtitleTable >>= (\b -> map (\x -> head x >>= HTS.fromElement) (HC.toArray b)) >>= maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableBody")) pure
  rows <- HTS.rows tbody
  rowArray <- HC.toArray rows
  lastRow <-  maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableLastRow")) pure (last rowArray)
  clonedRow <- deepClone (HE.toNode lastRow)
  --TODO: cloned row start time to end time. End time to start time + 1000
  appendChild clonedRow (HTS.toNode tbody)
  log "Subtitle row cloned successfully"
