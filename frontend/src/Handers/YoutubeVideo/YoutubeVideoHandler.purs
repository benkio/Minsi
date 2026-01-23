module Handers.YoutubeVideo.YoutubeVideoHandler where

import Data.Foldable (foldl)
import Data.Maybe (Maybe, maybe)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (invalid)
import Effect (Effect)
import Effect.Console (log)
import Handers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude
import Validations.YoutubeValidation (youtubeUrlValidation)
import Web.DOM.Element (fromEventTarget, toEventTarget)
import Web.Event.Event (target)
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener)
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSpanElement as HSP
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Components.HtmlIds (resultPreviewId)
import Handers.YoutubeVideo.Foreign (embedVideo)
import Handers.YoutubeVideo.YoutubeUrlExtraction (extractYoutubeVideoId, extractYoutubeVideoStartTime)
import Handers.YoutubeVideo.CutButtonsHandlers (initializeCutInputs, setCutEndButtonEvL, setCutStartButtonEvL)
import Handers.YoutubeVideo.PlaybackPositionHandler (updatePlaybackPosition)
import Effect.Timer (setInterval)

data VideoEventTargets = VET
  { cutStart :: HI.HTMLInputElement
  , cutEnd :: HI.HTMLInputElement
  , playbackPosition :: HSP.HTMLSpanElement
  , setCutEndButton :: HB.HTMLButtonElement
  , setCutStartButton :: HB.HTMLButtonElement
  }

setVideoHandlers :: VideoEventTargets -> EventTarget -> Effect Unit
setVideoHandlers (VET { cutStart, setCutStartButton, playbackPosition, cutEnd, setCutEndButton }) ytUrlEventTarget = do
  ytEvL <- eventListener (youtubeUrlEventListener cutStart cutEnd)
  addEventListener E.input ytEvL false ytUrlEventTarget
  addEventListener E.change ytEvL false ytUrlEventTarget
  _ <- setInterval 1000 (updatePlaybackPosition playbackPosition)
  setCutStartButtonEvLV <- eventListener (setCutStartButtonEvL cutStart)
  setCutEndButtonEvLV <- eventListener (setCutEndButtonEvL cutEnd)
  addEventListener E.click setCutStartButtonEvLV false setCutStartButtonTarget
  addEventListener E.click setCutEndButtonEvLV false setCutEndButtonTarget
  pure unit
  where
    setCutStartButtonTarget = toEventTarget (HB.toElement setCutStartButton)
    setCutEndButtonTarget = toEventTarget (HB.toElement setCutEndButton)

youtubeUrlEventListener :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
youtubeUrlEventListener cutStart cutEnd ev = genericErrorsHandler $ do
  rawValue <- getInputValue ev
  let youtubeUrlV = maybe (invalid [ "Empty YoutubeUrl Input" ]) youtubeUrlValidation rawValue
  youtubeUrl <- foldl (\_ v -> pure v) (throwMinsiError (InvalidInput (show rawValue))) youtubeUrlV
  videoId <- (maybe (throwMinsiError (InvalidInput (show rawValue))) pure <<< extractYoutubeVideoId) youtubeUrl
  let startTime = extractYoutubeVideoStartTime youtubeUrl
  log ("Youtube Url Handler fired with value: " <> show videoId)
  embedVideo { resultPreviewId: resultPreviewId, videoId: videoId, width: 1000, height: 500, startTime: startTime }
  initializeCutInputs cutStart cutEnd startTime

getInputValue :: Event -> Effect (Maybe String)
getInputValue ev =
  traverse (HI.value) (target ev >>= fromEventTarget >>= HI.fromElement)
