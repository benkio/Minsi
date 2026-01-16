module Components.HTMLComponentsLoader where

import Prelude (bind, pure, show, (<<<), (>>=))
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Web.HTML.HTMLButtonElement as HB
import Main.MinsiErrors (MinsiError(..))
import Effect (Effect)
import Data.Maybe (maybe)

loadInputComponentById :: String -> NonElementParentNode -> Effect HTMLInputElement
loadInputComponentById id doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= HI.fromElement
  maybe (throwError (HTMLElementNotFound id)) pure maybeComponentElement

loadVideoComponentById :: String -> NonElementParentNode -> Effect HTMLVideoElement
loadVideoComponentById id doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= HV.fromElement
  maybe (throwError (HTMLElementNotFound id)) pure maybeComponentElement

loadButtonComponentById :: String -> NonElementParentNode -> Effect HTMLButtonElement
loadButtonComponentById id doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= HB.fromElement
  maybe (throwError (HTMLElementNotFound id)) pure maybeComponentElement
