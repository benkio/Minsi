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

--- Add subtitle logic Frontend ---
- artist as dropdown with bots names
- new dropdown for filename prefix
- Enable the usage of local file
- Add keyboard shortcut:
  - ctrl+s - cut start
  - ctrl+e - cut end
  - alt+s - sub cut start
  - alt+e - sub cut end
  - + - add sub
  - right-left - for the video
  - space - play/pause
- Add the full transcript of the subtitles
-}
