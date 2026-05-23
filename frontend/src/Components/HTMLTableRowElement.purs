module Components.HTMLTableRowElement where

import Prelude

import Data.Array (drop, head)
import Data.Maybe (maybe)
import Effect (Effect)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.Element (toParentNode)
import Web.DOM.HTMLCollection as HC
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML.HTMLInputElement (HTMLInputElement, setValue)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLTableCellElement as HTC
import Web.HTML.HTMLTableRowElement as HTR

cellIndexes :: Map String (Tuple Number String)
cellIndexes = fromFoldable $
              zipWithIndex [
                Tuple "Start"     "input"
                Tuple "End"       "input"
                Tuple "Content"   "textarea"
                Tuple "FontColor" "select"
                Tuple "Size"      "select"
                Tuple "Position"  "select"
                ]

-- | Get the end input element from a table row (second cell)
getTableElement :: String -> HTR.HTMLTableRowElement -> Effect HTMLInputElement
getTableElement key row = do
  let cellKey = "SubtitleTable" <> key <> "Cell"
  Tuple cellIndex cellElement <- maybe (throwMinsiError (HTMLElementNotFound cellKey)) pure $ lookup key cellIndexes
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  cell <- maybe (throwMinsiError (HTMLElementNotFound cellKey)) pure
    (cellArray !! cellIndex) >>= HTC.fromElement)
  let element = HTC.toElement cell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector cellElement) parentNode
  input <- maybe (throwMinsiError (HTMLElementNotFound cellKey)) pure
    (elementMaybe >>= HI.fromElement)
  pure input

setTableElement :: String -> Number -> HTR.HTMLTableRowElement -> Effect Unit
setTableElement key value row = do
  let cellKey = "SubtitleTable" <> key <> "Cell"
  Tuple cellIndex cellElement <- maybe (throwMinsiError (HTMLElementNotFound cellKey)) pure $ lookup key cellIndexes
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  cell <- maybe (throwMinsiError (HTMLElementNotFound cellKey)) pure
    (cellArray !! cellIndex) >>= HTC.fromElement)
  let element = HTC.toElement cell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector cellElement) parentNode
  element <- maybe (throwMinsiError (HTMLElementNotFound cellKey)) pure
    (elementMaybe >>= HI.fromElement)
  setValue (show value) element
