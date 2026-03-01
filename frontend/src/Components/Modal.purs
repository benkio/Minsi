module Components.Modal where

import Components.HTMLComponentsLoader (loadHtmlElementId)
import Components.HtmlIdAndClasses (blockingModalBodyId)
import Components.Window (getDocument)
import Effect (Effect)
import Prelude
import Web.DOM.Node (appendChild, setTextContent)
import Web.HTML.HTMLElement (HTMLElement)
import Web.HTML.HTMLElement as HE

foreign import showModal :: String -> Boolean -> Effect Unit
foreign import hideModal :: String -> Effect Unit

setBlockingModalBody :: HTMLElement -> Effect Unit
setBlockingModalBody bodyEl = do
  doc <- getDocument
  container <- loadHtmlElementId blockingModalBodyId HE.fromElement doc
  let containerNode = HE.toNode container
  setTextContent "" containerNode
  void $ appendChild (HE.toNode bodyEl) containerNode
