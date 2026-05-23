module Handlers.Subtitles.SortSubtitlesButtonHandler where

import Prelude

import Components.HTMLTableElement (getRows, setRows)
import Components.HTMLTableRowElement (getStartInput)
import Data.Array (sortBy, reverse)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Console (log)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_sortSubtitlesButton, _subtitleTable)
import Data.Lens (view)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLTableElement as HT

setSortSubtitlesButtonHandler :: Effect Unit
setSortSubtitlesButtonHandler = genericErrorsHandler do
  components <- loadComponents
  let
    sortSubtitlesButton = view _sortSubtitlesButton components
    subtitleTable = view _subtitleTable components
    sortSubtitlesButtonEventTarget = toEventTarget (HB.toElement sortSubtitlesButton)
  sortSubtitlesButtonEvL <- eventListener (sortSubtitlesButtonEventListener subtitleTable)
  addEventListener E.click sortSubtitlesButtonEvL false sortSubtitlesButtonEventTarget

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
