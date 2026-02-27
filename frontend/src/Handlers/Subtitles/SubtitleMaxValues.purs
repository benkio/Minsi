module Handlers.Subtitles.SubtitleMaxValues where

import Prelude

import Components.HTMLTableElement (getRows, getStartInput)
import Components.HTMLTableRowElement (getEndInput)
import Components.HTMLTemplateElement (getRow)
import Data.Array (cons)
import Data.Time.Duration (Milliseconds(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Console (log)
import Model.State.State (DurationRange(..), State(..))
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTemplateElement as HTP

durationMillis :: DurationRange -> Number
durationMillis (DurationRange { start: Milliseconds startMs, end: Milliseconds endMs }) = endMs - startMs

setSubtitleTableMaxValues :: State -> HT.HTMLTableElement -> HTP.HTMLTemplateElement -> Effect Unit
setSubtitleTableMaxValues (State { cutVideo }) subtitleTable subtitleRowTemplate = do
  let durationSeconds = durationMillis cutVideo
  subtitleRow <- getRow subtitleRowTemplate
  rows <- getRows subtitleTable
  void $ traverse
    ( \row -> do
        startInput <- getStartInput row
        endInput <- getEndInput row
        HI.setMax (show durationSeconds) startInput
        HI.setMax (show durationSeconds) endInput
    )
    (cons subtitleRow rows)
  log $ "Set max values for all subtitle inputs to " <> show durationSeconds <> " millis"
