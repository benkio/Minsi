module Handlers.DownloadAllButtonHandler where

import Data.Newtype (unwrap)
import Data.Tuple (fst)
import Effect (Effect)
import Effect.Aff (Aff, runAff_)
import Effect.Class (liftEffect)
import Endpoints.Download (triggerDownloadLink)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Model.State.StateFromHtml (getCurrentState)
import Prelude
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB

setDownloadAllButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setDownloadAllButtonHandler downloadAllButton = genericErrorsHandler $ do
  evL <- eventListener downloadAllButtonEventListener
  addEventListener E.click evL false (toEventTarget (HB.toElement downloadAllButton))

downloadAllButtonEventListener :: Event -> Effect Unit
downloadAllButtonEventListener _ = do
  stateComponents <- getCurrentState
  let filename = (unwrap (fst stateComponents)).filename
  runAff_ genericErrorsHandlerEither (downloadAll filename)

downloadAll :: String -> Aff Unit
downloadAll filename = do
  liftEffect (triggerDownloadLink filename "mp4")
  liftEffect (triggerDownloadLink filename "gif")
  liftEffect (triggerDownloadLink filename "mp3")
