module Handlers.DownloadAllButtonHandler where

import Prelude
import Data.Newtype (unwrap)
import Data.Tuple (fst)
import Effect (Effect)
import Effect.Aff (runAff_)
import Handlers.ApplyButtonHandler (getCurrentState)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
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
  void $ callDownload filename "video"
  void $ callDownload filename "gif"
  void $ callDownload filename "mp3"
