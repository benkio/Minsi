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

-- | Get the end input element from a table row (second cell)
getEndInput :: HTR.HTMLTableRowElement -> Effect HTMLInputElement
getEndInput row = do
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  endCell <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableEndCell")) pure
    (head (drop 1 cellArray) >>= HTC.fromElement)
  let element = HTC.toElement endCell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "input") parentNode
  input <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableEndInput")) pure
    (elementMaybe >>= HI.fromElement)
  pure input

setEndInput :: Number -> HTR.HTMLTableRowElement -> Effect Unit
setEndInput value row = do
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  endCell <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableEndCell")) pure
    (head (drop 1 cellArray) >>= HTC.fromElement)
  let element = HTC.toElement endCell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "input") parentNode
  input <- maybe (throwMinsiError (HTMLElementNotFound "SubtitleTableEndInput")) pure
    (elementMaybe >>= HI.fromElement)
  setValue (show value) input
