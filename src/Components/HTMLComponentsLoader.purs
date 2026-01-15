module Components.HTMLComponentsLoader where

import Prelude (bind, pure, show, (<<<), (>>=))
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV
import Errors (Error(..))
import Effect (Effect)
import Data.Maybe (maybe)
import Effect.Exception (throwException, error)

loadInputComponentById :: String -> NonElementParentNode -> Effect HTMLInputElement
loadInputComponentById id doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= HI.fromElement
  maybe ((throwException <<< error <<< show) (HTMLElementNotFound id)) pure maybeComponentElement

loadVideoComponentById :: String -> NonElementParentNode -> Effect HTMLVideoElement
loadVideoComponentById id doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= HV.fromElement
  maybe ((throwException <<< error <<< show) (HTMLElementNotFound id)) pure maybeComponentElement
