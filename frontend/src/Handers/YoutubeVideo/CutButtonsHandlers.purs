module Handers.YoutubeVideo.CutButtonsHandlers where

import Control.Monad.Loops (whileM_)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (delay, launchAff_)
import Effect.Class (liftEffect)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSpanElement as HSP
import Handers.YoutubeVideo.Foreign (getPlayerCurrentTime, getVideoDuration, isPlayerReady)
import Handlers.CutRangeHandler (updateCutStartValue, updateCutEndValue, updateCutValue)
import Prelude

setCutInputButtonEvL :: HI.HTMLInputElement -> HSP.HTMLSpanElement -> Event -> Effect Unit
setCutInputButtonEvL cutInput cutValueSpan _ = do
  currentTime <- getPlayerCurrentTime
  HI.setValue (show currentTime) cutInput
  updateCutValue cutInput cutValueSpan

initializeCutInputs :: HI.HTMLInputElement -> HI.HTMLInputElement -> HSP.HTMLSpanElement -> HSP.HTMLSpanElement -> Int -> Effect Unit
initializeCutInputs cutStart cutEnd cutStartValue cutEndValue startTime = launchAff_ $ do
  whileM_ (liftEffect (not <$> isPlayerReady)) (delay (Milliseconds 500.0))
  duration <- liftEffect getVideoDuration
  liftEffect $ HI.setMax (show duration) cutStart
  liftEffect $ HI.setValue (show startTime) cutStart
  liftEffect $ HI.setMax (show duration) cutEnd
  liftEffect $ updateCutStartValue cutStart cutStartValue
  liftEffect $ updateCutEndValue cutEnd cutEndValue
