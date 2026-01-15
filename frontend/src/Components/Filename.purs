module Components.Filename where

import Web.DOM.NonElementParentNode (NonElementParentNode)
import Effect (Effect)
import Web.HTML.HTMLInputElement (HTMLInputElement)
import Components.HtmlIds (outputFilenameId)
import Components.HTMLComponentsLoader (loadInputComponentById)

loadFilename :: NonElementParentNode -> Effect HTMLInputElement
loadFilename = loadInputComponentById outputFilenameId
