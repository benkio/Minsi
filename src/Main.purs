module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)
import Components.HtmlComponents (loadComponents)

-- - load components
-- - check dependencies
-- - register eventhandlers
-- - use a state represenation of the input where you go from components <-> state at each onchange (elmlike)
main :: Effect Unit
main = do
    doc <- getDocument
    components <- loadComponents doc
    log "Components correctly loaded"

getDocument :: Effect NonElementParentNode
getDocument = do
    w <- window
    d <- document w
    pure $ toNonElementParentNode d
