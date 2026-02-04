module Handlers.ApplyButtonHandler where

import Prelude

import Web.HTML.HTMLSourceElement (HTMLSourceElement)
import Web.HTML.HTMLSourceElement as HSC
import Web.HTML.HTMLSelectElement as HS
import Data.Array (cons)
import Data.Tuple (Tuple(..), fst, snd)
import Model.State.State (State(..), DurationRange(..))
import Components.HtmlComponents (HtmlComponents, HtmlInputs(..), HtmlVisualElements(..), loadComponents)
import Components.HtmlIds (loadingModalId, videoSourceId)
import Components.Modal (hideModal, showModal)
import Components.Window (getDocument)
import Constants (mp4, gif, mp3)
import Control.Monad.Rec.Class (Step(..), tailRecM)
import Data.Either (either)
import Data.Newtype (unwrap)
import Data.Time.Duration (Milliseconds(..))
import Data.Validation.Semigroup (toEither)
import Effect (Effect)
import Effect.Aff (Aff, delay, runAff_, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Endpoints.Compute (callCompute)
import Endpoints.Status (callStatus)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Data.Maybe (maybe)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.ProcessStatus (ProcessStatus(..))
import Model.State.StateFromHtml (fromHtmlInputs)
import Model.ValidationErrors (toMap)
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element (toEventTarget)
import Web.DOM.Element as Element
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML (window)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLDivElement as HTMLDivElement
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLMediaElement (load, pause)
import Web.HTML.HTMLVideoElement (HTMLVideoElement)
import Web.HTML.HTMLVideoElement as HV
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HR
import Web.HTML.HTMLTemplateElement as HTP
import Web.DOM.DocumentFragment as DF
import Web.DOM.ParentNode (firstElementChild)
import Components.HTMLTableElement (getRows, getStartInput, getEndInput)
import Data.Traversable (traverse)
import Web.HTML.Location (setHash)
import Web.HTML.Window (location)
import Effect.Now (now)
import Data.DateTime.Instant (unInstant)

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
  let filename = (unwrap state).filename
  showModal loadingModalId
  runAff_
    (\result -> genericErrorsHandlerEither result) $
    finally (liftEffect (finallyHandlers components state)) (void (callCompute state) *> waitForStatus filename)

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
    videoMediaElement = (unwrap components.htmlOutputs).resultVideo
    videoSourceMediaElement = (unwrap components.htmlOutputs).resultVideoSource
    videoSourceElement = (unwrap components.htmlInputs).videoSource
  setVideoSrc filename videoMediaElement videoSourceElement videoSourceMediaElement
  let HtmlInputs { subtitleTable, subtitleRow } = components.htmlInputs
  setSubtitleTableMaxValues state subtitleTable subtitleRow

waitForStatus :: String -> Aff Unit
waitForStatus filename = tailRecM pollStatus unit
  where
  pollStatus _ = do
    response <- callStatus filename
    case response.status of
      Pending -> delay (Milliseconds 500.0) $> Loop unit
      Succeed -> pure $ Done unit
      (Failed error) -> liftEffect $ throwMinsiError (ComputeFailed ("Video download failed: " <> error))

setVideoSrc :: String -> HTMLVideoElement -> HS.HTMLSelectElement -> HTMLSourceElement -> Effect Unit
setVideoSrc filename video videoSource resultVideoSource = do
  (Milliseconds m) <- unInstant <$> now
  let videoMedia = HV.toHTMLMediaElement video
  pause videoMedia
  --TODO: test. if doesn't work. Try by creating the source on the spot and append it as child. Last resort. Try change element type
  Element.removeAttribute "src" (HV.toElement video)
  Element.removeAttribute "src" (HSC.toElement resultVideoSource)
  selectedVideoSourceValue <- HS.value videoSource
  filepathType <- case selectedVideoSourceValue of
    "gif" -> pure $ Tuple (gif filename) "video/mp4"
    "video" -> pure $ Tuple (mp4 filename) "video/mp4"
    "mp3" -> pure $ Tuple (mp3 filename) "audio/mpeg"
    x -> throwMinsiError (InvalidInput "videoSource" ("Value " <> x <> " not recognized as valid input"))
  let filePathNoCache = (fst filepathType) <> "?t=" <> show m
  Element.setAttribute "src" filePathNoCache (HSC.toElement resultVideoSource)
  HSC.setType (snd filepathType) resultVideoSource
  load videoMedia

showHiddenElements :: HtmlVisualElements -> Boolean -> Effect Unit
showHiddenElements (HtmlVisualElements { videoSourceRow, videoRow, subtitlesRow, playbackPositionResultRow }) reverseLoop = do
  removeClass "d-none" videoSourceRow
  removeClass "d-none" videoRow
  if reverseLoop then addClass "d-none" subtitlesRow else removeClass "d-none" subtitlesRow
  removeClass "d-none" playbackPositionResultRow

removeClass :: String -> HTMLDivElement.HTMLDivElement -> Effect Unit
removeClass className div = do
  let element = HTMLDivElement.toElement div
  classList <- Element.classList element
  containsClassName <- DOMTokenList.contains classList className
  when containsClassName $ DOMTokenList.remove classList className

addClass :: String -> HTMLDivElement.HTMLDivElement -> Effect Unit
addClass className div = do
  let element = HTMLDivElement.toElement div
  classList <- Element.classList element
  containsClassName <- DOMTokenList.contains classList className
  unless containsClassName $ DOMTokenList.remove classList className

scrollToVideoSource :: Effect Unit
scrollToVideoSource = do
  w <- window
  loc <- location w
  setHash ("#" <> videoSourceId) loc

getCurrentState :: Effect (Tuple State HtmlComponents)
getCurrentState = do
  doc <- getDocument
  components <- loadComponents doc
  stateV <- fromHtmlInputs components.htmlInputs
  state <- (either (throwMinsiError <<< InvalidInputs <<< toMap) pure <<< toEither) stateV
  pure $ Tuple state components

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

getRow :: HTP.HTMLTemplateElement -> Effect HR.HTMLTableRowElement
getRow subtitleTemplateElement = do
  fragment <- HTP.content subtitleTemplateElement
  firstEl <- firstElementChild (DF.toParentNode fragment)
  maybe (throwMinsiError (HTMLElementNotFound "subtitleRowTemplate")) pure
    (firstEl >>= HR.fromElement)
