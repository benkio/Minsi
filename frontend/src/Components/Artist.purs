module Components.Artist where

import Effect (Effect)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Components.HtmlIds (artistId)
import Components.HTMLComponentsLoader (loadInputComponentById)

loadArtist :: NonElementParentNode -> Effect HTMLInputElement
loadArtist = loadInputComponentById artistId
