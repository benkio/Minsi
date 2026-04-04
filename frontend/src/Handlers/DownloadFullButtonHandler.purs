module Handlers.DownloadFullButtonHandler where

import Prelude

import Components.HtmlIdAndClasses (loadingModalId)
import Components.Modal (hideModal, showModal)
import Data.Newtype (unwrap)
import Data.Tuple (fst)
import Effect (Effect)
import Effect.Aff (runAff_, finally)
import Effect.Class (liftEffect)
import Endpoints.Download (callDownload)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB

setDownloadFullButtonHandler :: HB.HTMLButtonElement -> Effect Unit
setDownloadFullButtonHandler downloadFullButton = genericErrorsHandler $ do
  evL <- eventListener downloadFullButtonEventListener
  addEventListener E.click evL false (toEventTarget (HB.toElement downloadFullButton))

downloadFullButtonEventListener :: Event -> Effect Unit
downloadFullButtonEventListener _ = do
  stateTuple <- getCurrentState
  let source = (unwrap (fst stateTuple)).source
  showModal loadingModalId true
  runAff_ genericErrorsHandlerEither $ finally (liftEffect $ hideModal loadingModalId) (callDownload source)
