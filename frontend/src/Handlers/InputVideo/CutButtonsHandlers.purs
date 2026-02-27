module Handlers.InputVideo.CutButtonsHandlers where

import Prelude

import Components.HtmlComponents (loadComponents)
import Control.Monad.Loops (whileM_)
import Data.Int (floor, toNumber)
import Data.Newtype (unwrap)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (delay, launchAff_)
import Effect.Class (liftEffect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.InputVideo.Foreign (getPlayerCurrentTime, getVideoDuration, isPlayerReady)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI

setCutStartInputButtonEvL :: Event -> Effect Unit
setCutStartInputButtonEvL _ = genericErrorsHandler $ do
  components <- loadComponents
  let cutStart = (unwrap components.htmlInputs).cutStart
  currentTimeSeconds <- getPlayerCurrentTime
  let currentTimeMs = currentTimeSeconds * 1000.0
  HI.setValue (show (floor currentTimeMs)) cutStart

setCutEndInputButtonEvL :: Event -> Effect Unit
setCutEndInputButtonEvL _ = genericErrorsHandler $ do
  components <- loadComponents
  let cutEnd = (unwrap components.htmlInputs).cutEnd
  currentTimeSeconds <- getPlayerCurrentTime
  let currentTimeMs = currentTimeSeconds * 1000.0
  HI.setValue (show (floor currentTimeMs)) cutEnd

initializeCutInputs :: Int -> Effect Unit
initializeCutInputs startTime = launchAff_ $ do
  components <- liftEffect loadComponents
  whileM_ (liftEffect (not <$> isPlayerReady)) (delay (Milliseconds 500.0))
  durationSeconds <- liftEffect getVideoDuration
  liftEffect $ setCutInputValues components durationSeconds
  where
  setCutInputValues components durationSeconds = do
    let
      cutStart = (unwrap components.htmlInputs).cutStart
      cutEnd = (unwrap components.htmlInputs).cutEnd
      durationMs = durationSeconds * 1000.0
      startTimeMs = toNumber startTime * 1000.0
    HI.setMax (show (floor durationMs)) cutStart
    HI.setValue (show (floor startTimeMs)) cutStart
    HI.setMax (show (floor durationMs)) cutEnd
