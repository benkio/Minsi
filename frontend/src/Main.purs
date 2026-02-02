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
-------Bugs-------------------
- when subtitles are invalid the backend is called. Show the error on the log instead.
- minsi log not showing stuff anymore (eg. empty artist)
- after cutting and reloading the video shows the video even if the videosource is gif.
------Improvements------------
- Minsi background
- improve error Video Download Failed
- Docker support
- When the cut end and cut start aren't changed, skip the yt-dlp step and just create the gifs
------Additions---------------
- artist as dropdown with bots names and filename prefix
- Enable the usage of local file
- Add the full transcript of the subtitles and export of client compute payload
- Download Button
-----keyboard shortcut for----
- removing/adding the table row
- cut start/end
- set start/end subtitle
-}
