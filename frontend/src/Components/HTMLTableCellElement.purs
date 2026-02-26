module HTMLTableCellElement where

import Data.Int (floor)
import Data.Maybe (Maybe(..), maybe)
import Effect (Effect)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude (bind, identity, pure, show, ($), (<#>), (<>), (>>=), (>>>))
import Web.DOM.Element (Element, toParentNode)
import Web.DOM.ParentNode (QuerySelector(..), querySelector)
import Web.HTML.HTMLInputElement (valueAsNumber)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTableCellElement as HTC
import Web.HTML.HTMLTextAreaElement as HTA

valueFromSelectTableCell :: Int -> String -> Element -> Effect String
valueFromSelectTableCell index cellDescription element =
  maybe
    (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: " <> cellDescription)))
    pure
    (HTC.fromElement element)
    >>= getSelectValueFromCell

valueFromTextAreaTableCell :: Int -> String -> Element -> Effect String
valueFromTextAreaTableCell index cellDescription element =
  maybe
    (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: " <> cellDescription)))
    pure
    (HTC.fromElement element)
    >>= getTextAreaValueFromCell

valueFromInputTableCell :: Int -> String -> Int -> Element -> Effect Int
valueFromInputTableCell index cellDescription default element =
  maybe
    (throwMinsiError (HTMLElementNotFound ("[Subtitle row " <> show index <> "]: " <> cellDescription)))
    pure
    (HTC.fromElement element)
    >>= getInputValueFromCell
    >>= \v -> pure $ maybe default identity v

getInputValueFromCell :: HTC.HTMLTableCellElement -> Effect (Maybe Int)
getInputValueFromCell cell = do
  let element = HTC.toElement cell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "input") parentNode
  let inputMaybe = elementMaybe >>= HI.fromElement
  case inputMaybe of
    Nothing -> pure Nothing
    Just input -> valueAsNumber input <#> floor >>> Just

getTextAreaValueFromCell :: HTC.HTMLTableCellElement -> Effect String
getTextAreaValueFromCell cell = do
  let element = HTC.toElement cell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "textarea") parentNode
  let textareaMaybe = elementMaybe >>= HTA.fromElement
  case textareaMaybe of
    Nothing -> pure ""
    Just textarea -> HTA.value textarea

getSelectValueFromCell :: HTC.HTMLTableCellElement -> Effect String
getSelectValueFromCell cell = do
  let element = HTC.toElement cell
  let parentNode = toParentNode element
  elementMaybe <- querySelector (QuerySelector "select") parentNode
  let selectMaybe = elementMaybe >>= HS.fromElement
  case selectMaybe of
    Nothing -> pure ""
    Just select -> HS.value select
