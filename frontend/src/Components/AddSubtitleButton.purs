module Components.AddSubtitleButton where

import Effect (Effect)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Components.HtmlIds (addSubtitleId)
import Components.HTMLComponentsLoader (loadButtonComponentById)

loadAddSubtitleButton :: NonElementParentNode -> Effect HTMLButtonElement
loadAddSubtitleButton = loadButtonComponentById addSubtitleId
