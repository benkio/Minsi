module Components.HTMLDivElement where

import Effect (Effect)
import Prelude
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element as Element
import Web.HTML.HTMLDivElement as HTMLDivElement

addClass :: String -> HTMLDivElement.HTMLDivElement -> Effect Unit
addClass className div = do
  let element = HTMLDivElement.toElement div
  cls <- Element.classList element
  containsClassName <- DOMTokenList.contains cls className
  unless containsClassName $ DOMTokenList.add cls className

removeClass :: String -> HTMLDivElement.HTMLDivElement -> Effect Unit
removeClass className div = do
  let element = HTMLDivElement.toElement div
  cls <- Element.classList element
  containsClassName <- DOMTokenList.contains cls className
  when containsClassName $ DOMTokenList.remove cls className
