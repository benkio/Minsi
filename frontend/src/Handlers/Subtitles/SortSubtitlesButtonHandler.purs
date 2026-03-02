module Handlers.Subtitles.SortSubtitlesButtonHandler where

import Prelude

import Components.HTMLTableElement (getRows, getStartInput, setRows)
import Data.Array (sortBy, reverse)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLTableElement as HT

setSortSubtitlesButtonHandler :: HB.HTMLButtonElement -> HT.HTMLTableElement -> Effect Unit
setSortSubtitlesButtonHandler sortSubtitlesButton subtitleTable = genericErrorsHandler do
  sortSubtitlesButtonEvL <- eventListener (sortSubtitlesButtonEventListener subtitleTable)
  addEventListener E.click sortSubtitlesButtonEvL false sortSubtitlesButtonEventTarget
  where
  sortSubtitlesButtonEventTarget = toEventTarget (HB.toElement sortSubtitlesButton)

sortSubtitlesButtonEventListener :: HT.HTMLTableElement -> Event -> Effect Unit
sortSubtitlesButtonEventListener table _ = genericErrorsHandler do
  log "[SortSubtitlesButton] Sorting rows by start time"
  rows <- getRows table
  rowsWithStart <-
    traverse
      ( \row -> do
          startInput <- getStartInput row
          start <- HI.valueAsNumber startInput
          pure { row, start }
      )
      rows
  let sortedRows = (reverse <<< map _.row <<< sortBy (comparing _.start)) rowsWithStart
  setRows sortedRows table
  log "[SortSubtitlesButton] Sorted rows by start time"
