module Components.CutVideoButton where

import Effect (Effect)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Components.HtmlIds (cutVideoId)
import Components.HTMLComponentsLoader (loadButtonComponentById)

loadCutVideoButton :: NonElementParentNode -> Effect HTMLButtonElement
loadCutVideoButton = loadButtonComponentById cutVideoId
