module Handlers.DownloadFullButtonHandler where

import Prelude

import Components.HtmlIdAndClasses (loadingModalId)
import Components.Modal (hideModal)
import Data.Either (Either(..))
import Data.Tuple (fst)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Class (liftEffect)
import Endpoints.Download (callDownload)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_downloadFullButton)
import Data.Lens (view)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Model.State.Lenses (_source)
import Model.State.StateFromHtml (getCurrentState)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB

setDownloadFullButtonHandler :: Effect Unit
setDownloadFullButtonHandler = do
  components <- loadComponents
  let downloadFullButton = view _downloadFullButton components
  evL <- eventListener downloadFullButtonEventListener
  addEventListener E.click evL false (toEventTarget (HB.toElement downloadFullButton))

downloadFullButtonEventListener :: Event -> Effect Unit
downloadFullButtonEventListener _ = genericErrorsHandler $ do
  stateTuple <- getCurrentState
  let source = view _source (fst stateTuple)
  runAff_
    ( \result -> do
        case result of
          Left _ -> liftEffect $ hideModal loadingModalId
          Right _ -> pure unit
        genericErrorsHandlerEither result
    )
    (callDownload source)
