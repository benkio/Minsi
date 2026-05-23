module Components.HTMLTableElement where

import Prelude

import Data.Array (catMaybes, head, last)
import Data.Maybe (maybe)
import Data.Traversable (traverse_)
import Data.TraversableWithIndex (traverseWithIndex)
import Effect (Effect)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (Subtitle)
import Web.DOM.Node (appendChild, removeChild)
import Web.DOM.HTMLCollection as HC
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

-- | Set table's body to the list of array rows
setRows :: Array HTR.HTMLTableRowElement -> HT.HTMLTableElement -> Effect Unit
setRows rows table = do
  tbody <- getTBody table
  existingRows <- getRows table
  traverse_ (\row -> removeChild (HTR.toNode row) (HTS.toNode tbody)) existingRows
  traverse_ (\row -> appendChild (HTR.toNode row) (HTS.toNode tbody)) rows

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

loadSubtitlesFromTable :: (Int -> HTR.HTMLTableRowElement -> Effect Subtitle) -> HT.HTMLTableElement -> Effect (Array Subtitle)
loadSubtitlesFromTable loadSubtitleFromRow table = do
  rows <- getRows table
  subtitles <- traverseWithIndex loadSubtitleFromRow rows
  pure subtitles
