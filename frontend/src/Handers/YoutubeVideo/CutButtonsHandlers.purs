module Handers.YoutubeVideo.CutButtonsHandlers where

import Data.Int (floor, toNumber)
import Control.Monad.Loops (whileM_)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (delay, launchAff_)
import Effect.Class (liftEffect)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI
import Handers.YoutubeVideo.Foreign (getPlayerCurrentTime, getVideoDuration, isPlayerReady)
import Handlers.CutRangeHandler (updateCutValue)
import Prelude

setCutInputButtonEvL :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
setCutInputButtonEvL cutInput cutValueInput _ = do
  currentTimeSeconds <- getPlayerCurrentTime
  let currentTimeMs = currentTimeSeconds * 1000.0
  HI.setValue (show (floor currentTimeMs)) cutInput
  updateCutValue currentTimeMs cutValueInput

initializeCutInputs :: HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Int -> Effect Unit
initializeCutInputs cutStart cutEnd cutStartValue cutEndValue startTime = launchAff_ $ do
  whileM_ (liftEffect (not <$> isPlayerReady)) (delay (Milliseconds 500.0))
  durationSeconds <- liftEffect getVideoDuration
  let durationMs = durationSeconds * 1000.0
  let startTimeMs = toNumber startTime * 1000.0
  liftEffect $ HI.setMax (show (floor durationMs)) cutStart
  liftEffect $ HI.setValue (show (floor startTimeMs)) cutStart
  liftEffect $ HI.setMax (show (floor durationMs)) cutEnd
  liftEffect $ updateCutValue startTimeMs cutStartValue
  liftEffect $ updateCutValue startTimeMs cutEndValue
