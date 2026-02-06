module Endpoints.Download where

import Constants (fromType, suggestedDownloadName)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Prelude
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Document (createElement)
import Web.DOM.Element (toNode)
import Web.DOM.Node (appendChild, removeChild)
import Web.HTML (window)
import Web.HTML.HTMLAnchorElement as HA
import Web.HTML.HTMLDocument (body, toDocument)
import Web.HTML.HTMLElement (click, toElement) as HE
import Web.HTML.HTMLHyperlinkElementUtils (setHref)
import Web.HTML.Window (document)

triggerDownload :: String -> String -> Aff Unit
triggerDownload filename filetype = liftEffect (triggerDownloadLink filename filetype)

-- | Trigger browser download via a temporary anchor pointing at the static file (virtual anchor).
triggerDownloadLink :: String -> String -> Effect Unit
triggerDownloadLink filename filetype = do
  w <- window
  htmlDoc <- document w
  doc <- pure (toDocument htmlDoc)
  el <- createElement (unsafeCoerce "a") doc
  maybe (pure unit) (go htmlDoc) (HA.fromElement el)
  where
  downloadUrl = (fromType filetype) filename
  suggestedName = suggestedDownloadName filename filetype
  go doc' anchor = do
    setHref downloadUrl (HA.toHTMLHyperlinkElementUtils anchor)
    HA.setDownload suggestedName anchor
    mBody <- body doc'
    maybe (pure unit) (appendAndClick anchor) mBody
  appendAndClick anchor b = do
    let anchorNode = HA.toNode anchor
    let bodyNode = toNode (HE.toElement b)
    appendChild anchorNode bodyNode
    HE.click (HA.toHTMLElement anchor)
    removeChild anchorNode bodyNode
