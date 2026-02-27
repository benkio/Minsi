module Handlers.ResultVideo.MediaSrc where

import Prelude

import Components.HTMLElement (showElementHideOther)
import Components.HTMLMediaElement (setMediaSrcAndLoad)
import Constants (mp4, gif, mp3)
import Data.DateTime.Instant (unInstant)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Now (now)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.Element as Element
import Web.HTML.HTMLAudioElement (HTMLAudioElement)
import Web.HTML.HTMLAudioElement as HA
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV

pathForVideoSource :: String -> String -> Effect String
pathForVideoSource selectedVideoSourceValue filename =
  case selectedVideoSourceValue of
    "mp4" -> pure (mp4 filename)
    "gif" -> pure (gif filename)
    "mp3" -> pure (mp3 filename)
    x -> throwMinsiError (InvalidInput "videoSource" ("Value " <> x <> " not recognized as valid input"))

isVideoSource :: String -> Boolean
isVideoSource v = v == "mp4" || v == "gif"

setResultMediaSrc :: String -> HS.HTMLSelectElement -> HTMLVideoElement -> HTMLAudioElement -> Effect Unit
setResultMediaSrc filename videoSource resultVideo resultAudio = do
  (Milliseconds m) <- unInstant <$> now
  selectedVideoSourceValue <- HS.value videoSource
  path <- pathForVideoSource selectedVideoSourceValue filename
  let filePathNoCache = path <> "?t=" <> show m
  Element.removeAttribute "src" (HV.toElement resultVideo)
  Element.removeAttribute "src" (HA.toElement resultAudio)
  if isVideoSource selectedVideoSourceValue then setResultVideoSrcAndVisibility filePathNoCache resultVideo resultAudio
  else setResultAudioSrcAndVisibility filePathNoCache resultVideo resultAudio

setResultVideoSrcAndVisibility :: String -> HTMLVideoElement -> HTMLAudioElement -> Effect Unit
setResultVideoSrcAndVisibility filePathNoCache resultVideo resultAudio = do
  setMediaSrcAndLoad filePathNoCache (HV.toHTMLMediaElement resultVideo)
  showElementHideOther (HV.toElement resultVideo) (HA.toElement resultAudio)

setResultAudioSrcAndVisibility :: String -> HTMLVideoElement -> HTMLAudioElement -> Effect Unit
setResultAudioSrcAndVisibility filePathNoCache resultVideo resultAudio = do
  setMediaSrcAndLoad filePathNoCache (HA.toHTMLMediaElement resultAudio)
  showElementHideOther (HA.toElement resultAudio) (HV.toElement resultVideo)
