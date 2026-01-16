module Components.HTMLComponentsLoader where

import Prelude (bind, pure, (>>=))
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Web.HTML.HTMLButtonElement as HB
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Effect (Effect)
import Data.Maybe (Maybe(..))

loadInputComponentById :: String -> NonElementParentNode -> Effect HTMLInputElement
loadInputComponentById id doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= HI.fromElement
  case maybeComponentElement of
    Nothing -> throwMinsiError (HTMLElementNotFound id)
    Just element -> pure element

loadVideoComponentById :: String -> NonElementParentNode -> Effect HTMLVideoElement
loadVideoComponentById id doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= HV.fromElement
  case maybeComponentElement of
    Nothing -> throwMinsiError (HTMLElementNotFound id)
    Just element -> pure element

loadButtonComponentById :: String -> NonElementParentNode -> Effect HTMLButtonElement
loadButtonComponentById id doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= HB.fromElement
  case maybeComponentElement of
    Nothing -> throwMinsiError (HTMLElementNotFound id)
    Just element -> pure element
