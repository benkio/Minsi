module Components.HTMLTableElement where

import Prelude

import Data.Array (catMaybes, head, last)
import Data.Maybe (maybe)
import Data.TraversableWithIndex (traverseWithIndex)
import Effect (Effect)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.State.State (Subtitle)
import Web.DOM.Element (toParentNode)
import Web.DOM.HTMLCollection as HC
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLTableCellElement as HTC
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HTR
import Web.HTML.HTMLTableSectionElement as HTS

-- | Get the tbody element from a table
getTBody :: HT.HTMLTableElement -> Effect HTS.HTMLTableSectionElement
getTBody table = do
  tBodies <- HT.tBodies table
  tBodyArray <- HC.toArray tBodies
  maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableBody")) pure
    $ (head tBodyArray >>= HTS.fromElement)

-- | Get an array of all rows from a table's tbody
getRows :: HT.HTMLTableElement -> Effect (Array HTR.HTMLTableRowElement)
getRows table = do
  tbody <- getTBody table
  rows <- HTS.rows tbody
  rowArray <- HC.toArray rows
  pure $ catMaybes $ map HTR.fromElement rowArray

-- | Get the first row from a table
getFirstRow :: HT.HTMLTableElement -> Effect HTR.HTMLTableRowElement
getFirstRow table = do
  rows <- getRows table
  maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableFirstRow")) pure
    $ head rows

-- | Get the last row from a table
getLastRow :: HT.HTMLTableElement -> Effect HTR.HTMLTableRowElement
getLastRow table = do
  rows <- getRows table
  maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableLastRow")) pure
    $ last rows

-- | Get the start input element from a table row (first cell)
getStartInput :: HTR.HTMLTableRowElement -> Effect HTMLInputElement
getStartInput row = do
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  startCell <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableStartCell")) pure
    $ (head cellArray >>= HTC.fromElement)
  let element = HTC.toElement startCell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "input") parentNode
  input <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableStartInput")) pure
    $ (elementMaybe >>= HI.fromElement)
  pure input

loadSubtitlesFromTable :: (Int -> HTR.HTMLTableRowElement -> Effect Subtitle) -> HT.HTMLTableElement -> Effect (Array Subtitle)
loadSubtitlesFromTable loadSubtitleFromRow table = do
  rows <- getRows table
  subtitles <- traverseWithIndex loadSubtitleFromRow rows
  pure subtitles
