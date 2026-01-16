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
    -- Initialize State
    -- check dependencies: yt-dlp,ffmpeg...
    -- add yt handler + FFI iframe API + enable the rest of the control + spin
    -- add slider cut logic UI constraint: cstartmax<cendmin, cendmax < yt video length, cstart < cend values
    -- add subtitle logic UI constraint: 0-max length of yt cut
    -- Consider a single button (or none, with hotreload always) for elaborating async and a control to signal the video is ready
    -- Idea: add a control for current video position to facilitate the insertion of subtitles
    -- Idea: dropdown to switch from video to GIF to compare the 2.

errorsHandler :: Error -> Effect Unit
errorsHandler e = do
  w <- window
  alert ("🚫 An error occurred: " <> message e) w


getDocument :: Effect NonElementParentNode
getDocument = do
    w <- window
    d <- document w
    pure $ toNonElementParentNode d
