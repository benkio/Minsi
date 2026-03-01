module Main.CheckUpdates where

import Prelude

import Components.HTMLDivElement (removeClass)
import Components.HtmlComponents (HtmlVisualElements(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Endpoints.UpdateCheck (UpdateCheckResponse, callUpdateCheck)

checkUpdates :: HtmlVisualElements -> Aff Unit
checkUpdates (HtmlVisualElements { updateAvailableBanner }) = do
  { updateAvailable } :: UpdateCheckResponse <- callUpdateCheck
  when updateAvailable (liftEffect (removeClass "d-none" updateAvailableBanner))
