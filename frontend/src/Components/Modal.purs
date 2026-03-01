module Components.Modal where

import Components.HTMLComponentsLoader (loadHtmlElementId)
import Components.HtmlIdAndClasses (blockingModalActionId, blockingModalBodyId)
import Components.Window (getDocument)
import Data.Maybe (Maybe(..), isJust)
import Effect (Effect)
import Prelude
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element as Element
import Web.DOM.Node (setTextContent)

foreign import showModal :: String -> Effect Unit
foreign import hideModal :: String -> Effect Unit

setBlockingModalBody :: String -> Effect Unit
setBlockingModalBody bodyText = do
  doc <- getDocument
  bodyEl <- loadHtmlElementId blockingModalBodyId Just doc
  setTextContent bodyText (Element.toNode bodyEl)

setBlockingModalAction :: Maybe { label :: String, href :: String } -> Effect Unit
setBlockingModalAction action = do
  doc <- getDocument
  actionEl <- loadHtmlElementId blockingModalActionId Just doc
  let shouldShow = isJust action
  cls <- Element.classList actionEl
  if shouldShow then DOMTokenList.remove cls "d-none" else DOMTokenList.add cls "d-none"
  case action of
    Nothing -> do
      setTextContent "" (Element.toNode actionEl)
      Element.setAttribute "href" "#" actionEl
    Just { label, href } -> do
      setTextContent label (Element.toNode actionEl)
      Element.setAttribute "href" href actionEl
