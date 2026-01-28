module Main where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.Window (getDocument)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Console (log)
import Handers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Handlers.Handlers (setupEventHandlers)
import Main.CheckDependencies (checkDependecies)

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

- Apply button handler:
  - Change the text of the modal: replace the spinner with an emoji, show it for a sec and then move to the next phase.

--- Add subtitle logic Frontend ---
- Add the button handler for adding more subtitles
- (maybe) Add a button to send the subtitles, probably a clone of the ApplyButton or really similar
- Add buttons in the start/end of each subtitle row that sets the value to the current position of teh video.
-}
