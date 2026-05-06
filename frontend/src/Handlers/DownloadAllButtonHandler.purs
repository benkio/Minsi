module Handlers.DownloadAllButtonHandler where

import Data.Tuple (fst)
import Effect (Effect)
import Effect.Aff (Aff, runAff_)
import Effect.Class (liftEffect)
import Endpoints.Download (triggerDownloadLink)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_downloadAllButton)
import Data.Lens (view)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Model.State.Lenses (_filename)
import Model.State.StateFromHtml (getCurrentState)
import Prelude
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB

setDownloadAllButtonHandler :: Effect Unit
setDownloadAllButtonHandler = genericErrorsHandler $ do
  components <- loadComponents
  let downloadAllButton = view _downloadAllButton components
  evL <- eventListener downloadAllButtonEventListener
  addEventListener E.click evL false (toEventTarget (HB.toElement downloadAllButton))

downloadAllButtonEventListener :: Event -> Effect Unit
downloadAllButtonEventListener _ = do
  stateComponents <- getCurrentState
  let filename = view _filename (fst stateComponents)
  runAff_ genericErrorsHandlerEither (downloadAll filename)

downloadAll :: String -> Aff Unit
downloadAll filename = liftEffect do
  triggerDownloadLink filename "mp4"
  triggerDownloadLink filename "gif"
  triggerDownloadLink filename "mp3"
