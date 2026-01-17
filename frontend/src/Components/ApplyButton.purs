module Components.ApplyButton where

import Effect (Effect)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Components.HtmlIds (applyId)
import Components.HTMLComponentsLoader (loadButtonComponentById)

loadApplyButton :: NonElementParentNode -> Effect HTMLButtonElement
loadApplyButton = loadButtonComponentById applyId
