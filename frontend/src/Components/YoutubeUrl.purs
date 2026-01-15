module Components.YoutubeUrl where

import Effect (Effect)
import Components.HtmlIds (youtubeUrlId)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Components.HTMLComponentsLoader (loadInputComponentById)

loadYoutubeUrl :: NonElementParentNode -> Effect HTMLInputElement
loadYoutubeUrl = loadInputComponentById youtubeUrlId
