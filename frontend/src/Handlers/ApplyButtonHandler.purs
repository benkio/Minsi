module Handlers.ApplyButtonHandler where

import Prelude

import Components.HTMLDivElement (addClass, removeClass)
import Components.HTMLElement (showElementHideOther)
import Components.HTMLMediaElement (setMediaSrcAndLoad)
import Components.HTMLTableElement (getRows, getStartInput)
import Components.HTMLTableRowElement (getEndInput)
import Components.HTMLTemplateElement (getRow)
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlVisualElements(..))
import Components.HtmlIds (loadingModalId, videoSourceId)
import Components.Modal (hideModal, showModal)
import Constants (mp4, gif, mp3)
import Control.Monad.Rec.Class (Step(..), tailRecM)
import Data.Array (cons, dropWhile)
import Data.DateTime.Instant (unInstant)
import Data.Newtype (unwrap)
import Data.Time.Duration (Milliseconds(..))
import Data.Traversable (traverse)
import Data.Tuple (fst, snd)
import Data.String.CodeUnits (fromCharArray, toCharArray)
import Effect (Effect)
import Effect.Aff (Aff, delay, runAff_, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Now (now)
import Endpoints.Compute (callCompute)
import Endpoints.Status (callStatus)
import Endpoints.Upload (callUpload)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ProcessStatus (ProcessStatus(..))
import Model.State.State (DurationRange(..), State(..), Source(..), isLocalFile)
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.DOM.Element as Element
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLAudioElement (HTMLAudioElement)
import Web.HTML.HTMLAudioElement as HA
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTemplateElement as HTP
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV
import Web.HTML.Location (setHash)
import Web.HTML.Window (location)
import Web.File.File (name)

setApplyButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setApplyButtonHandler applyButton = genericErrorsHandler $ do
  applyButtonEvL <- eventListener applyButtonEventListener
  addEventListener E.click applyButtonEvL false applyButtonEventTarget
  where
  applyButtonEventTarget = toEventTarget (HB.toElement applyButton)

applyButtonEventListener :: Event -> Effect Unit
applyButtonEventListener _ = genericErrorsHandler $ do
  stateComponents <- getCurrentState
  let state = fst stateComponents
  let components = snd stateComponents
  let localFileInput = (unwrap components.htmlInputs).localFile
  showModal loadingModalId
  runAff_
    (\result -> genericErrorsHandlerEither result) $
    finally (liftEffect (finallyHandlers components state)) (applyButtonLogic state localFileInput)

applyButtonLogic :: State -> HI.HTMLInputElement -> Aff Unit
applyButtonLogic state localFileInput = genericErrorsHandler $ do
  let
    uploadLocalFile = (unwrap state).uploadLocalFile
    filename = (unwrap state).filename
    source = (unwrap state).source
  when (uploadLocalFile && isLocalFile source) (uploadLocalFileLogic source filename localFileInput)
  waitForStatus filename LocalFileUploaded
  void (callCompute state)
  waitForStatus filename Succeed

uploadLocalFileLogic :: Source -> String -> HI.HTMLInputElement -> Aff Unit
uploadLocalFileLogic (LocalFile file) filename localFileInput = genericErrorsHandler $ do
  let diskFilename = name file
  let
    diskFileExt = fromCharArray $ dropWhile (_ /= '.') (toCharArray diskFilename)
    fullFileName = filename <> diskFileExt
  liftEffect $ log $ "Upload Local File " <> fullFileName
  void $ callUpload file fullFileName
  liftEffect $ log $ "Set localFileInput to False"
  liftEffect $ HI.setChecked false localFileInput
uploadLocalFileLogic x _ _ = liftEffect $ throwMinsiError (InvalidInput "StateSource" ("Expected LocalFile, got " <> show x))

finallyHandlers :: HtmlComponents -> State -> Effect Unit
finallyHandlers components state = do
  let reverseLoop = (unwrap state).reverseLoop
  let filename = (unwrap state).filename
  log "return from server, show elements and set src"
  showHiddenElements components.htmlVisualElements reverseLoop
  log "hide modal, and scroll"
  hideModal loadingModalId
  scrollToVideoSource
  let
    resultVideo = (unwrap components.htmlOutputs).resultVideo
    resultAudio = (unwrap components.htmlOutputs).resultAudio
    videoSourceElement = (unwrap components.htmlInputs).videoSource
  setResultMediaSrc filename videoSourceElement resultVideo resultAudio
  let HtmlInputs { subtitleTable, subtitleRow } = components.htmlInputs
  setSubtitleTableMaxValues state subtitleTable subtitleRow

waitForStatus :: String -> ProcessStatus -> Aff Unit
waitForStatus filename target = tailRecM pollStatus unit
  where
  pollStatus _ = do
    response <- callStatus filename
    case response.status of
      (Failed error) -> liftEffect $ throwMinsiError (ComputeFailed ("Video download failed: " <> error))
      status | status == target -> pure $ Done unit
      _ -> delay (Milliseconds 500.0) $> Loop unit

setResultMediaSrc :: String -> HS.HTMLSelectElement -> HTMLVideoElement -> HTMLAudioElement -> Effect Unit
setResultMediaSrc filename videoSource resultVideo resultAudio = do
  (Milliseconds m) <- unInstant <$> now
  selectedVideoSourceValue <- HS.value videoSource
  path <- case selectedVideoSourceValue of
    "mp4" -> pure (mp4 filename)
    "gif" -> pure (gif filename)
    "mp3" -> pure (mp3 filename)
    x -> throwMinsiError (InvalidInput "videoSource" ("Value " <> x <> " not recognized as valid input"))
  let showVideo = selectedVideoSourceValue == "mp4" || selectedVideoSourceValue == "gif"
  let filePathNoCache = path <> "?t=" <> show m
  Element.removeAttribute "src" (HV.toElement resultVideo)
  Element.removeAttribute "src" (HA.toElement resultAudio)
  if showVideo then setResultVideoSrcAndVisibility filePathNoCache resultVideo resultAudio
  else setResultAudioSrcAndVisibility filePathNoCache resultVideo resultAudio

setResultVideoSrcAndVisibility :: String -> HTMLVideoElement -> HTMLAudioElement -> Effect Unit
setResultVideoSrcAndVisibility filePathNoCache resultVideo resultAudio = do
  setMediaSrcAndLoad filePathNoCache (HV.toHTMLMediaElement resultVideo)
  showElementHideOther (HV.toElement resultVideo) (HA.toElement resultAudio)

setResultAudioSrcAndVisibility :: String -> HTMLVideoElement -> HTMLAudioElement -> Effect Unit
setResultAudioSrcAndVisibility filePathNoCache resultVideo resultAudio = do
  setMediaSrcAndLoad filePathNoCache (HA.toHTMLMediaElement resultAudio)
  showElementHideOther (HA.toElement resultAudio) (HV.toElement resultVideo)

showHiddenElements :: HtmlVisualElements -> Boolean -> Effect Unit
showHiddenElements (HtmlVisualElements { videoSourceRow, videoRow, subtitlesRow, playbackPositionResultRow }) reverseLoop = do
  removeClass "d-none" videoSourceRow
  removeClass "d-none" videoRow
  if reverseLoop then addClass "d-none" subtitlesRow else removeClass "d-none" subtitlesRow
  removeClass "d-none" playbackPositionResultRow

scrollToVideoSource :: Effect Unit
scrollToVideoSource = do
  w <- window
  loc <- location w
  setHash ("#" <> videoSourceId) loc

setSubtitleTableMaxValues :: State -> HT.HTMLTableElement -> HTP.HTMLTemplateElement -> Effect Unit
setSubtitleTableMaxValues (State { cutVideo: DurationRange { start: Milliseconds startMs, end: Milliseconds endMs } }) subtitleTable subtitleRowTemplate = do
  let durationSeconds = (endMs - startMs)
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
