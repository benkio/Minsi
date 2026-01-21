module Main where

import Handers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.Window (getDocument)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Console (log)
import Main.CheckDependencies (checkDependecies)
import Handlers.Handlers (setupEventHandlers)

main :: Effect Unit
main = genericErrorsHandler program

program :: Effect Unit
program = do
  runAff_ genericErrorsHandlerEither checkDependecies
  doc <- getDocument
  htmlComponents <- loadComponents doc
  log "Components correctly loaded"
  setupEventHandlers htmlComponents
  log "Setup Handlers Done"

-- TODOs --------------------------------
{-

- add yt handler + FFI iframe API + enable the rest of the control
- Add the Apply button handler that takes the htmlinputs, convert
  them to state and send them to the compute endpoint if the
  conversion is successful. disable the button until the call ends. animate the message section
- add slider cut logic UI constraint: cstartmax<cendmin, cendmax < yt video length, cstart < cend values
-- add subtitle logic UI constraint: 0-max length of yt cut and more...
-}
