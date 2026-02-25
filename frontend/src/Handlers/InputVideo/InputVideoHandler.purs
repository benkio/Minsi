module Handlers.InputVideo.InputVideoHandler where

import Prelude

import Components.HtmlComponents (loadComponents, resultPreviewToMaybeIframe, resultPreviewToMaybeVideo)
import Components.HtmlIds (resultPreviewId, youtubeUrlId)
import Data.Foldable (foldl)
import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (unwrap)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (invalid)
import Effect (Effect)
import Effect.Console (log)
import Effect.Timer (setInterval)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.InputVideo.CutButtonsHandlers (initializeCutInputs, setCutInputButtonEvL)
import Handlers.InputVideo.Foreign (destroyIFramePlayer,   embedIFrameVideo)
import Handlers.InputVideo.PlaybackPositionHandler (updatePlaybackPosition)
import Handlers.InputVideo.YoutubeUrlExtraction (extractYoutubeVideoId, extractYoutubeVideoStartTime)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.ValidationErrors (fromSingleton)
import Validations.YoutubeValidation (youtubeUrlValidation)
import Web.DOM.Element (fromEventTarget, toEventTarget, toNode)
import Web.DOM.Node (appendChild, parentNode, removeChild)
import Web.Event.Event (target)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLIFrameElement as IF
import Web.HTML.HTMLInputElement as HI
import Web.File.File (toBlob)
import Web.File.FileList (item)
import Web.File.Url (createObjectURL)
import Web.HTML.HTMLMediaElement (setSrc)
import Web.HTML.HTMLSpanElement as HSP
import Web.HTML.HTMLVideoElement as HV

data VideoEventTargets = VET
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
  , playbackPositionYoutube :: HSP.HTMLSpanElement
  , setCutEndButton :: HB.HTMLButtonElement
  , setCutStartButton :: HB.HTMLButtonElement
  , youtubeUrl :: HI.HTMLInputElement
  , localFile :: HI.HTMLInputElement
  }

setVideoHandlers :: VideoEventTargets -> Effect Unit
setVideoHandlers
  ( VET
      { cutStart
      , setCutStartButton
      , playbackPositionYoutube
      , cutEnd
      , setCutEndButton
      , youtubeUrl
      , localFile
      }
  ) = genericErrorsHandler $ do
  ytEvL <- eventListener (youtubeUrlEventListener cutStart cutEnd)
  lfEvL <- eventListener localFileEventListener
  addEventListener E.input ytEvL false ytUrlEventTarget
  addEventListener E.change ytEvL false ytUrlEventTarget
  addEventListener E.input lfEvL false localFileEventTarget
  addEventListener E.change lfEvL false localFileEventTarget
  _ <- setInterval 1000 (updatePlaybackPosition playbackPositionYoutube)
  setCutStartButtonEvLV <- eventListener (setCutInputButtonEvL cutStart)
  setCutEndButtonEvLV <- eventListener (setCutInputButtonEvL cutEnd)
  addEventListener E.click setCutStartButtonEvLV false setCutStartButtonTarget
  addEventListener E.click setCutEndButtonEvLV false setCutEndButtonTarget
  pure unit
  where
  ytUrlEventTarget = (toEventTarget <<< HI.toElement) youtubeUrl
  localFileEventTarget = (toEventTarget <<< HI.toElement) localFile
  setCutStartButtonTarget = toEventTarget (HB.toElement setCutStartButton)
  setCutEndButtonTarget = toEventTarget (HB.toElement setCutEndButton)

youtubeUrlEventListener :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
youtubeUrlEventListener cutStart cutEnd ev = genericErrorsHandler $ do
  rawValue <- getInputValue ev
  let youtubeUrlV = maybe (invalid (fromSingleton youtubeUrlId "Empty YoutubeUrl Input")) (\v -> youtubeUrlValidation youtubeUrlId v) rawValue
  source <- foldl (\_ v -> pure v) (throwMinsiError (InvalidInput youtubeUrlId (show rawValue))) youtubeUrlV
  videoId <- (maybe (throwMinsiError (InvalidInput youtubeUrlId (show rawValue))) pure <<< extractYoutubeVideoId) source
  let startTime = extractYoutubeVideoStartTime source
  log ("Youtube Url Handler fired with value: " <> show videoId)
  embedIFrameVideo
    { resultPreviewId: resultPreviewId
    , videoId: videoId
    , width: 1000
    , height: 500
    , startTime: startTime
    }
  initializeCutInputs cutStart cutEnd startTime

getInputValue :: Event -> Effect (Maybe String)
getInputValue ev =
  traverse (HI.value) (target ev >>= fromEventTarget >>= HI.fromElement)

localFileEventListener :: Event -> Effect Unit
localFileEventListener _ = genericErrorsHandler $ do
  components <- loadComponents
  let resultPreview = (unwrap components.htmlOutputs).resultPreview
  maybe (pure unit)
    ( \_ -> do
         log "Descroy YT IFrame"
         destroyIFramePlayer
    )
    (resultPreviewToMaybeIframe resultPreview)
  newComponents <- loadComponents
  let newResultPreview = (unwrap newComponents.htmlOutputs).resultPreview
      localFileInput = (unwrap newComponents.htmlInputs).localFile
  maybe (throwMinsiError (HTMLElementNotFound "resultPreviewId"))
      ( \video -> do
           fileListMaybe <- HI.files localFileInput
           maybe
             (pure unit)
             (\file -> do
                 blobUrl <- createObjectURL (toBlob file)
                 setSrc blobUrl (HV.toHTMLMediaElement video)
             ) (fileListMaybe >>= item 0)
      )
      (resultPreviewToMaybeVideo newResultPreview)
