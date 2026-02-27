module Components.HTMLComponentsLoader where

import Data.Maybe (Maybe, maybe)
import Effect (Effect)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude (bind, pure, (>>=))
import Web.DOM.Document as Document
import Web.DOM.HTMLCollection (HTMLCollection)
import Web.DOM.Internal.Types (Element)
import Web.DOM.NonElementParentNode (NonElementParentNode, getElementById)

loadHtmlElementId :: forall a. String -> (Element -> Maybe a) -> NonElementParentNode -> Effect a
loadHtmlElementId id f doc = do
  maybeComponent <- getElementById id doc
  let maybeComponentElement = maybeComponent >>= f
  maybe (throwMinsiError (HTMLElementNotFound id)) pure maybeComponentElement

loadHtmlElementClass :: String -> NonElementParentNode -> Effect HTMLCollection
loadHtmlElementClass className doc =
  maybe
    (throwMinsiError (HTMLElementNotFound className))
    (Document.getElementsByClassName className)
    (Document.fromNonElementParentNode doc)
