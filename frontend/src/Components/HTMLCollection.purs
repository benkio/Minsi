module Components.HTMLCollection where

import Prelude

import Data.Traversable (traverse_)
import Effect (Effect)
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element (classList)
import Web.DOM.HTMLCollection as HC

swapClasses :: String -> String -> HC.HTMLCollection -> Effect Unit
swapClasses from to collection = do
  elements <- HC.toArray collection
  traverse_
    ( \el -> do
        cls <- classList el
        DOMTokenList.remove cls from
        DOMTokenList.add cls to
    )
    elements
