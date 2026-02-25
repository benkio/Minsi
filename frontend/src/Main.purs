module Main where

import Prelude

import Components.HtmlComponents (loadComponents)
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
  htmlComponents <- loadComponents
  log "Components correctly loaded"
  setupEventHandlers htmlComponents
  log "Setup Handlers Done"

-- TODOs --------------------------------
{-
-------Bugs-------------------
------Improvements------------
- Add health check and add a step in CI to: build the docker image, run it, test the healthcheck endpoint
- Make minsilog red when there's an error
------Additions---------------
- Enable the usage of local file
- Button to Export client compute payload (maybe directly the curl command)
- Option to compute from payload
-----keyboard shortcut for----
- cut start/end
- set start/end subtitle
-}

{-
FE DONE:
  - Send the filename+file extension as well using form data
    - ✅ Add a boolean in state to signal the need to upload the file, when:
    - ✅ The cut is changed
    - ✅ filename is changed.
    - ✅ localfile is changed
    ✅ It starts as true
  - in compute.
    - ✅ localfile is selected and the upload is true. Send it. Put the upload to false

BE:
    - Upload: Normalize and Save/Overwrite the file
    - Compute w/ empty youtubeUrl: skip download, cut the file with
    ffmpeg, then gif, mp3 as usual
-}
