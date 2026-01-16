module Components.ApplySubtitleButton where

import Effect (Effect)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML.HTMLButtonElement (HTMLButtonElement)
import Components.HtmlIds (applySubtitleId)
import Components.HTMLComponentsLoader (loadButtonComponentById)

loadApplySubtitleButton :: NonElementParentNode -> Effect HTMLButtonElement
loadApplySubtitleButton = loadButtonComponentById applySubtitleId
