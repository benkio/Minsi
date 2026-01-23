module Handers.YoutubeVideo.CutButtonsHandlers where

import Control.Monad.Loops (whileM_)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (delay, launchAff_)
import Effect.Class (liftEffect)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI
import Handers.YoutubeVideo.Foreign (getPlayerCurrentTime, getVideoDuration, isPlayerReady)
import Prelude

setCutStartButtonEvL :: HI.HTMLInputElement -> Event -> Effect Unit
setCutStartButtonEvL cutStart _ = do
  currentTime <- getPlayerCurrentTime
  HI.setValue (show currentTime) cutStart

setCutEndButtonEvL :: HI.HTMLInputElement -> Event -> Effect Unit
setCutEndButtonEvL cutEnd _ = do
  currentTime <- getPlayerCurrentTime
  HI.setValue (show currentTime) cutEnd

initializeCutInputs :: HI.HTMLInputElement -> HI.HTMLInputElement -> Int -> Effect Unit
initializeCutInputs cutStart cutEnd startTime = launchAff_ $ do
  whileM_ (liftEffect (not <$> isPlayerReady)) (delay (Milliseconds 500.0))
  duration <- liftEffect getVideoDuration
  liftEffect $ HI.setMax (show duration) cutStart
  liftEffect $ HI.setValue (show startTime) cutStart
  liftEffect $ HI.setMax (show duration) cutEnd
