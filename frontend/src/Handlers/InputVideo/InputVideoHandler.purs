module Handlers.InputVideo.InputVideoHandler where

import Prelude

import Components.HtmlComponents (loadComponents, resultPreviewToMaybeIframe, resultPreviewToMaybeVideo)
import Components.HtmlComponents.Lenses (_localFile, _playbackPositionYoutube, _resultPreview, _setCutEndButton, _setCutStartButton, _uploadLocalFile, _youtubeUrl)
import Components.HtmlIdAndClasses (resultPreviewId, youtubeUrlId)
import Conversion.VideoUrlExtraction (extractVideoId, extractVideoStartTime)
import Data.Foldable (foldl)
import Data.Lens (view)
import Data.Maybe (Maybe, maybe)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (invalid)
import Effect (Effect)
import Effect.Console (log)
import Effect.Timer (setInterval)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.InputVideo.CutButtonsHandlers (initializeCutInputs, setCutStartInputButtonEvL, setCutEndInputButtonEvL)
import Handlers.InputVideo.Foreign (destroyIFramePlayer, embedIFrameVideo)
import Handlers.InputVideo.PlaybackPositionHandler (updatePlaybackPosition)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ValidationErrors (fromSingleton)
import Validations.VideoUrlValidation (videoUrlValidation)
import Web.DOM.Element (fromEventTarget, toEventTarget)
import Web.Event.Event (target)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.File.File (toBlob)
import Web.File.FileList (item)
import Web.File.Url (createObjectURL)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement (setChecked)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLMediaElement (setSrc)
import Web.HTML.HTMLVideoElement as HV

setVideoHandlers :: Effect Unit
setVideoHandlers = genericErrorsHandler $ do
  components <- loadComponents
  let
    playbackPositionYoutube = view _playbackPositionYoutube components
    setCutStartButton = view _setCutStartButton components
    setCutEndButton = view _setCutEndButton components
    localFile = view _localFile components
    youtubeUrl = view _youtubeUrl components
    ytUrlEventTarget = (toEventTarget <<< HI.toElement) youtubeUrl
    localFileEventTarget = (toEventTarget <<< HI.toElement) localFile
    setCutStartButtonTarget = toEventTarget (HB.toElement setCutStartButton)
    setCutEndButtonTarget = toEventTarget (HB.toElement setCutEndButton)
  ytEvL <- eventListener youtubeUrlEventListener
  lfEvL <- eventListener localFileEventListener
  addEventListener E.input ytEvL false ytUrlEventTarget
  addEventListener E.change ytEvL false ytUrlEventTarget
  addEventListener E.input lfEvL false localFileEventTarget
  addEventListener E.change lfEvL false localFileEventTarget
  _ <- setInterval 1000 (updatePlaybackPosition playbackPositionYoutube)
  setCutStartButtonEvLV <- eventListener setCutStartInputButtonEvL
  setCutEndButtonEvLV <- eventListener setCutEndInputButtonEvL
  addEventListener E.click setCutStartButtonEvLV false setCutStartButtonTarget
  addEventListener E.click setCutEndButtonEvLV false setCutEndButtonTarget
  pure unit

youtubeUrlEventListener :: Event -> Effect Unit
youtubeUrlEventListener ev = genericErrorsHandler $ do
  rawValue <- getInputValue ev
  let youtubeUrlV = maybe (invalid (fromSingleton youtubeUrlId "Empty YoutubeUrl Input")) (\v -> videoUrlValidation youtubeUrlId v) rawValue
  source <- foldl (\_ v -> pure v) (throwMinsiError (InvalidInput youtubeUrlId (show rawValue))) youtubeUrlV
  videoId <- (maybe (throwMinsiError (InvalidInput youtubeUrlId (show rawValue))) pure <<< extractVideoId) source
  let startTime = extractVideoStartTime source
  log ("Youtube Url Handler fired with value: " <> show videoId)
  embedIFrameVideo
    { resultPreviewId: resultPreviewId
    , videoId: videoId
    , width: 1000
    , height: 500
    , startTime: startTime
    }
  initializeCutInputs startTime

getInputValue :: Event -> Effect (Maybe String)
getInputValue ev =
  traverse (HI.value) (target ev >>= fromEventTarget >>= HI.fromElement)

localFileEventListener :: Event -> Effect Unit
localFileEventListener _ = genericErrorsHandler $ do
  components <- loadComponents
  let resultPreview = view _resultPreview components
  maybe (pure unit)
    (const (log "Descroy YT IFrame" *> destroyIFramePlayer))
    (resultPreviewToMaybeIframe resultPreview)
  newComponents <- loadComponents
  let
    newResultPreview = view _resultPreview newComponents
    localFileInput = view _localFile newComponents
    uploadLocalFileInput = view _uploadLocalFile newComponents
  maybe (throwMinsiError (HTMLElementNotFound "resultPreviewId"))
    ( \video -> do
        fileListMaybe <- HI.files localFileInput
        maybe
          (pure unit)
          ( \file -> do
              blobUrl <- createObjectURL (toBlob file)
              setSrc blobUrl (HV.toHTMLMediaElement video)
              log "[InputVideoHandler] set the uploadLocalFile to true"
              setChecked true uploadLocalFileInput
          )
          (fileListMaybe >>= item 0)
    )
    (resultPreviewToMaybeVideo newResultPreview)
