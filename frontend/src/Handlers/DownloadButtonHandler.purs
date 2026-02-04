module Handlers.DownloadButtonHandler where

import Prelude
import Data.Newtype (unwrap)
import Data.Tuple (fst)
import Effect (Effect)
import Effect.Aff (runAff_)
import Endpoints.Download (triggerDownload)
import Handlers.ApplyButtonHandler (getCurrentState)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLSelectElement as HS

setDownloadButtonHandler :: HB.HTMLButtonElement -> HS.HTMLSelectElement -> Effect Unit
setDownloadButtonHandler downloadButton videoSource = genericErrorsHandler $ do
  downloadButtonEvL <- eventListener (downloadButtonEventListener videoSource)
  addEventListener E.click downloadButtonEvL false (toEventTarget (HB.toElement downloadButton))

downloadButtonEventListener :: HS.HTMLSelectElement -> Event -> Effect Unit
downloadButtonEventListener videoSource _ = do
  stateComponents <- getCurrentState
  let state = fst stateComponents
  let filename = (unwrap state).filename
  selectedVideoSourceValue <- HS.value videoSource
  runAff_ genericErrorsHandlerEither (triggerDownload filename selectedVideoSourceValue)
