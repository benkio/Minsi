module Components.HTMLTableRowElement where

import Prelude

import Data.Array (length, range, zipWith, (!!))
import Data.Map as Map
import Data.Map (Map)
import Data.Maybe (Maybe, maybe)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.Element (Element, toParentNode)
import Web.DOM.HTMLCollection as HC
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTableCellElement as HTC
import Web.HTML.HTMLTableRowElement as HTR
import Web.HTML.HTMLTextAreaElement as HTA

-- | Columns in order with the tag used to locate the editable control inside the cell body.
subtitleCellSpecs :: Array (Tuple String String)
subtitleCellSpecs =
  [ Tuple "Start" "input"
  , Tuple "End" "input"
  , Tuple "Content" "textarea"
  , Tuple "FontColor" "select"
  , Tuple "Size" "select"
  , Tuple "Position" "select"
  ]

-- | Lookup by logical key → (column index, control tag query).
cellIndexes :: Map String (Tuple Int String)
cellIndexes =
  Map.fromFoldable $
    zipWith
      (\idx (Tuple k sel) -> Tuple k (Tuple idx sel))
      (range 0 (length subtitleCellSpecs - 1))
      subtitleCellSpecs

subtitleCellKeyError :: String -> MinsiError
subtitleCellKeyError key = HTMLElementNotFound ("SubtitleTable" <> key <> "Cell")

resolveSpec :: String -> Effect (Tuple Int String)
resolveSpec key =
  maybe (throwMinsiError $ subtitleCellKeyError key) pure $
    Map.lookup key cellIndexes

cellAtColumn :: HTR.HTMLTableRowElement -> Int -> Effect HTC.HTMLTableCellElement
cellAtColumn row cellIndex = do
  cells <- HTR.cells row
  cellArray <- HC.toArray cells
  raw <- maybe (throwMinsiError cellErr) pure $ cellArray !! cellIndex
  maybe (throwMinsiError cellErr) pure $ HTC.fromElement raw
  where
  cellErr :: MinsiError
  cellErr =
    HTMLElementNotFound $ "Subtitle row column " <> show cellIndex <> " missing or not a table cell"

-- | Locate the editable control (`input`, `textarea`, or `select`) inside the cell body.
queriedControlEl :: HTC.HTMLTableCellElement -> String -> Effect Element
queriedControlEl cell selectorTag = do
  let parentNode = toParentNode (HTC.toElement cell)
  elMaybe <- querySelector (QuerySelector selectorTag) parentNode
  maybe (throwMinsiError missingControl) pure elMaybe
  where
  missingControl :: MinsiError
  missingControl = HTMLElementNotFound $ "SubtitleCell <" <> selectorTag <> "> not found"

expectControl :: forall a. String -> Maybe a -> Effect a
expectControl tag =
  maybe throwMissing pure
  where
  throwMissing :: Effect a
  throwMissing =
    throwMinsiError
      $ HTMLElementNotFound
      $ "SubtitleCell expected element to be <" <> tag <> ">"

readControl :: String -> Element -> Effect String
readControl "input" el = do
  i <- expectControl "input" $ HI.fromElement el
  HI.value i

readControl "textarea" el = do
  t <- expectControl "textarea" $ HTA.fromElement el
  HTA.value t

readControl "select" el = do
  s <- expectControl "select" $ HS.fromElement el
  HS.value s

readControl selector _ =
  throwMinsiError
    $ HTMLElementNotFound
    $ "SubtitleCell unknown control type: " <> selector

writeControl :: String -> String -> Element -> Effect Unit
writeControl "input" val el = do
  i <- expectControl "input" $ HI.fromElement el
  HI.setValue val i

writeControl "textarea" val el = do
  t <- expectControl "textarea" $ HTA.fromElement el
  HTA.setValue val t

writeControl "select" val el = do
  s <- expectControl "select" $ HS.fromElement el
  HS.setValue val s

writeControl selector _ _ =
  throwMinsiError
    $ HTMLElementNotFound
    $ "SubtitleCell unknown control type: " <> selector

-- | Read the subtitle row column (Start, End, Content, FontColor, Size, Position).
getTableCellValue :: String -> HTR.HTMLTableRowElement -> Effect String
getTableCellValue key row = do
  Tuple cellIndex selectorTag <- resolveSpec key
  cell <- cellAtColumn row cellIndex
  controlEl <- queriedControlEl cell selectorTag
  readControl selectorTag controlEl

-- | Set a subtitle row column; use `show` for numeric timing fields (`Start`, `End`).
setTableCellValue :: String -> String -> HTR.HTMLTableRowElement -> Effect Unit
setTableCellValue key value row = do
  Tuple cellIndex selectorTag <- resolveSpec key
  cell <- cellAtColumn row cellIndex
  controlEl <- queriedControlEl cell selectorTag
  writeControl selectorTag value controlEl

-- | Second column timing input (`End`).
getEndInput :: HTR.HTMLTableRowElement -> Effect HI.HTMLInputElement
getEndInput row = loadInputCell "End" row

-- | First column timing input (`Start`).
getStartInput :: HTR.HTMLTableRowElement -> Effect HI.HTMLInputElement
getStartInput row = loadInputCell "Start" row

loadInputCell :: String -> HTR.HTMLTableRowElement -> Effect HI.HTMLInputElement
loadInputCell key row = do
  Tuple cellIndex selectorTag <- resolveSpec key
  if selectorTag /= "input" then
    throwMinsiError
      $ HTMLElementNotFound
      $ "SubtitleCell " <> key <> " is not an input column"
  else do
    cell <- cellAtColumn row cellIndex
    controlEl <- queriedControlEl cell selectorTag
    expectControl "input" $ HI.fromElement controlEl
