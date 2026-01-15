module Components.ResultPreview where

import Web.DOM.NonElementParentNode (NonElementParentNode)
import Effect (Effect)
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Components.HtmlIds (resultPreviewId)
import Components.HTMLComponentsLoader (loadVideoComponentById)

loadResultPreview :: NonElementParentNode -> Effect HTMLVideoElement
loadResultPreview = loadVideoComponentById resultPreviewId
