module Components.HTMLComponentsLoader where

import Data.Maybe (Maybe, maybe)
import Effect (Effect)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Prelude (bind, pure, (>>=))
import Web.DOM.Internal.Types (Element)
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)

loadHtmlElement :: forall a. String -> (Element -> Maybe a) -> NonElementParentNode -> Effect a
loadHtmlElement id f doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= f
  maybe (throwMinsiError (HTMLElementNotFound id)) pure maybeComponentElement
