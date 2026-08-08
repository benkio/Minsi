module Endpoints.Download where

import Constants (fromType, suggestedDownloadName)
import Conversion.YoutubeUrlExtraction (extractYoutubeVideoId)
import Data.Maybe (Maybe(..), maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Main.Config (backendUrl)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (Source(..), WURL(..))
import Prelude
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Document (createElement)
import Web.DOM.Element (toNode)
import Web.DOM.Node (appendChild, removeChild)
import Web.HTML (window)
import Web.HTML.HTMLAnchorElement as HA
import Web.HTML.HTMLDocument (body, toDocument)
import Web.HTML.HTMLElement as HE
import Web.HTML.HTMLHyperlinkElementUtils (setHref)
import Web.HTML.Window (document)

downloadEndpoint :: String
downloadEndpoint = backendUrl <> "download"

callDownload :: Source -> Aff Unit
callDownload (WebURL (WURL u)) = do
  let maybeVideoId = extractYoutubeVideoId u
  case maybeVideoId of
    Just videoId -> liftEffect $ triggerDownloadFromUrl (downloadEndpoint <> "/" <> videoId) (videoId <> ".mp4")
    Nothing -> liftEffect $ throwMinsiError (InvalidInput "downloadFull" "Could not extract a YouTube video id from the input URL.")
callDownload (LocalFile _) = do
  liftEffect $ throwMinsiError (InvalidInput "downloadFull" "Download Full supports URL sources only. Use Download All for local file results.")

triggerDownloadFromUrl :: String -> String -> Effect Unit
triggerDownloadFromUrl downloadUrl filename = do
  w <- window
  htmlDoc <- document w
  doc <- pure (toDocument htmlDoc)
  el <- createElement (unsafeCoerce "a") doc
  maybe (pure unit) (go htmlDoc downloadUrl filename) (HA.fromElement el)
  where
  go doc' href name anchor = do
    setHref href (HA.toHTMLHyperlinkElementUtils anchor)
    HA.setDownload name anchor
    mBody <- body doc'
    maybe (pure unit) (appendAndClick anchor) mBody

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

appendAndClick :: HA.HTMLAnchorElement -> HE.HTMLElement -> Effect Unit
appendAndClick anchor b = do
  let anchorNode = HA.toNode anchor
  let bodyNode = toNode (HE.toElement b)
  appendChild anchorNode bodyNode
  HE.click (HA.toHTMLElement anchor)
  removeChild anchorNode bodyNode
