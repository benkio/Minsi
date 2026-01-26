module Components.HTMLComponentsLoader where

import Prelude (bind, pure, (>>=))
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Effect (Effect)
import Data.Maybe (Maybe(..))
import Web.DOM.Internal.Types (Element)

loadHtmlElement :: forall a. String -> (Element -> Maybe a) -> NonElementParentNode -> Effect a
loadHtmlElement id f doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= f
  case maybeComponentElement of
    Nothing -> throwMinsiError (HTMLElementNotFound id)
    Just element -> pure element
