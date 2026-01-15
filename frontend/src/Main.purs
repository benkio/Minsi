module Main where

import Prelude

import Effect (Effect)
import Effect.Exception (Error, catchException, message)
import Effect.Console (log)
import Web.DOM.NonElementParentNode (NonElementParentNode)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document, alert)
import Components.HtmlComponents (loadComponents)

-- - load components
-- - check dependencies
-- - register eventhandlers
-- - use a state represenation of the input where you go from components <-> state at each onchange (elmlike)
main :: Effect Unit
main = catchException errorsHandler program

program :: Effect Unit
program = do
    doc <- getDocument
    components <- loadComponents doc
    log "Components correctly loaded"

errorsHandler :: Error -> Effect Unit
errorsHandler e = do
  w <- window
  alert ("🚫 An error occurred: " <> message e) w


getDocument :: Effect NonElementParentNode
getDocument = do
    w <- window
    d <- document w
    pure $ toNonElementParentNode d
