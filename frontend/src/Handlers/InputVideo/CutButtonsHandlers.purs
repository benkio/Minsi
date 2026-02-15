module Handlers.InputVideo.CutButtonsHandlers where

import Control.Monad.Loops (whileM_)
import Data.Int (floor, toNumber)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (delay, launchAff_)
import Effect.Class (liftEffect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Handlers.InputVideo.Foreign (getPlayerCurrentTime, getVideoDuration, isPlayerReady)
import Prelude
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI

setCutInputButtonEvL :: HI.HTMLInputElement -> Event -> Effect Unit
setCutInputButtonEvL cutInput _ = genericErrorsHandler $ do
  currentTimeSeconds <- getPlayerCurrentTime
  let currentTimeMs = currentTimeSeconds * 1000.0
  HI.setValue (show (floor currentTimeMs)) cutInput

initializeCutInputs :: HI.HTMLInputElement -> HI.HTMLInputElement -> Int -> Effect Unit
initializeCutInputs cutStart cutEnd startTime = launchAff_ $ do
  whileM_ (liftEffect (not <$> isPlayerReady)) (delay (Milliseconds 500.0))
  durationSeconds <- liftEffect getVideoDuration
  let durationMs = durationSeconds * 1000.0
  let startTimeMs = toNumber startTime * 1000.0
  liftEffect $ HI.setMax (show (floor durationMs)) cutStart
  liftEffect $ HI.setValue (show (floor startTimeMs)) cutStart
  liftEffect $ HI.setMax (show (floor durationMs)) cutEnd
