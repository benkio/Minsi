module Handlers.DownloadFullButtonHandler where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
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
  log "Download Full button clicked"
