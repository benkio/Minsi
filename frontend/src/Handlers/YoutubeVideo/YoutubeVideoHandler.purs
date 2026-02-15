module Handlers.YoutubeVideo.YoutubeVideoHandler where

import Components.HtmlIds (resultPreviewId, youtubeUrlId)
import Data.Foldable (foldl)
import Data.Maybe (Maybe, maybe)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (invalid)
import Effect (Effect)
import Effect.Console (log)
import Effect.Timer (setInterval)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.YoutubeVideo.CutButtonsHandlers (initializeCutInputs, setCutInputButtonEvL)
import Handlers.YoutubeVideo.Foreign (embedVideo)
import Handlers.YoutubeVideo.PlaybackPositionHandler (updatePlaybackPosition)
import Handlers.YoutubeVideo.YoutubeUrlExtraction (extractYoutubeVideoId, extractYoutubeVideoStartTime)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.ValidationErrors (fromSingleton)
import Prelude
import Validations.YoutubeValidation (youtubeUrlValidation)
import Web.DOM.Element (fromEventTarget, toEventTarget)
import Web.Event.Event (target)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSpanElement as HSP

data VideoEventTargets = VET
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
  , playbackPositionYoutube :: HSP.HTMLSpanElement
  , setCutEndButton :: HB.HTMLButtonElement
  , setCutStartButton :: HB.HTMLButtonElement
  , youtubeUrl :: HI.HTMLInputElement
  }

setVideoHandlers :: VideoEventTargets -> Effect Unit
setVideoHandlers
  ( VET
      { cutStart
      , setCutStartButton
      , playbackPositionYoutube
      , cutEnd
      , setCutEndButton
      , youtubeUrl: youtubeUrl
      }
  ) = genericErrorsHandler $ do
  ytEvL <- eventListener (youtubeUrlEventListener cutStart cutEnd)
  addEventListener E.input ytEvL false ytUrlEventTarget
  addEventListener E.change ytEvL false ytUrlEventTarget
  _ <- setInterval 1000 (updatePlaybackPosition playbackPositionYoutube)
  setCutStartButtonEvLV <- eventListener (setCutInputButtonEvL cutStart)
  setCutEndButtonEvLV <- eventListener (setCutInputButtonEvL cutEnd)
  addEventListener E.click setCutStartButtonEvLV false setCutStartButtonTarget
  addEventListener E.click setCutEndButtonEvLV false setCutEndButtonTarget
  pure unit
  where
  ytUrlEventTarget = toEventTarget (HI.toElement youtubeUrl)
  setCutStartButtonTarget = toEventTarget (HB.toElement setCutStartButton)
  setCutEndButtonTarget = toEventTarget (HB.toElement setCutEndButton)

youtubeUrlEventListener :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
youtubeUrlEventListener cutStart cutEnd ev = genericErrorsHandler $ do
  rawValue <- getInputValue ev
  let youtubeUrlV = maybe (invalid (fromSingleton youtubeUrlId "Empty YoutubeUrl Input")) (\v -> youtubeUrlValidation youtubeUrlId v) rawValue
  youtubeUrl <- foldl (\_ v -> pure v) (throwMinsiError (InvalidInput youtubeUrlId (show rawValue))) youtubeUrlV
  videoId <- (maybe (throwMinsiError (InvalidInput youtubeUrlId (show rawValue))) pure <<< extractYoutubeVideoId) youtubeUrl
  let startTime = extractYoutubeVideoStartTime youtubeUrl
  log ("Youtube Url Handler fired with value: " <> show videoId)
  embedVideo
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
