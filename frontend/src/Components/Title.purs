module Components.Title where

import Effect (Effect)
import Components.HtmlIds (titleId)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Components.HTMLComponentsLoader (loadInputComponentById)
import Web.HTML.HTMLInputElement (HTMLInputElement)

loadTitle :: NonElementParentNode -> Effect HTMLInputElement
loadTitle = loadInputComponentById titleId
