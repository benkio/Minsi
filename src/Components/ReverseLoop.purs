module Components.ReverseLoop where

import Web.DOM.NonElementParentNode (NonElementParentNode)
import Effect (Effect)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Components.HtmlIds (reverseLoopGifId)
import Components.HTMLComponentsLoader (loadInputComponentById)

loadReverseLoop :: NonElementParentNode -> Effect HTMLInputElement
loadReverseLoop = loadInputComponentById reverseLoopGifId
