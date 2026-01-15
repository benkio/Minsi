module Components.CutRange where

import Prelude
import Effect (Effect)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Data.Tuple (Tuple(..))
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Components.HtmlIds (cutStartId, cutEndId)
import Components.HTMLComponentsLoader (loadInputComponentById)

loadCutRange :: NonElementParentNode -> Effect (Tuple HTMLInputElement HTMLInputElement)
loadCutRange doc = do
  cutStart <- loadInputComponentById cutStartId doc
  cutEnd <- loadInputComponentById cutEndId doc
  pure $ Tuple cutStart cutEnd
