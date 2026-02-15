module Main where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.Window (getDocument)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
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
-------Bugs-------------------
------Improvements------------
- Remove files after Download and after 1h from creation
- When the cut end and cut start aren't changed, skip the yt-dlp step and just create the gifs
- Add health check and add a step in CI to: build the docker image, run it, test the healthcheck endpoint
- Make minsilog red when there's an error
------Additions---------------
- Enable the usage of local file
- Button to Export client compute payload (maybe directly the curl command)
- Option to compute from payload
-----keyboard shortcut for----
- removing/adding the table row
- cut start/end
- set start/end subtitle
-}
