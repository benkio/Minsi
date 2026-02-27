module Components.Window where

import Prelude
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Effect (Effect)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Location (setHash)
import Web.HTML.Window (alert, document, location)

getDocument :: Effect NonElementParentNode
getDocument = do
  w <- window
  d <- document w
  pure $ toNonElementParentNode d

raiseErrorAlert :: String -> Effect Unit
raiseErrorAlert msg =
  window >>= \w -> alert
    ( """😾!!! ERROR !!! 😾
""" <> msg
    )
    w

scrollToElement :: String -> Effect Unit
scrollToElement elementId = do
  w <- window
  loc <- location w
  setHash ("#" <> elementId) loc
