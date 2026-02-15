module Components.HTMLElement where

import Prelude

import Effect (Effect)
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element as Element

showElementHideOther :: Element.Element -> Element.Element -> Effect Unit
showElementHideOther toShow toHide = do
  removeClassFromElement "d-none" toShow
  addClassToElement "d-none" toHide

removeClassFromElement :: String -> Element.Element -> Effect Unit
removeClassFromElement className element = do
  classList <- Element.classList element
  containsClassName <- DOMTokenList.contains classList className
  when containsClassName $ DOMTokenList.remove classList className

addClassToElement :: String -> Element.Element -> Effect Unit
addClassToElement className element = do
  classList <- Element.classList element
  containsClassName <- DOMTokenList.contains classList className
  unless containsClassName $ DOMTokenList.add classList className
