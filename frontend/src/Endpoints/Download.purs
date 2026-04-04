module Endpoints.Download where

import Constants (fromType, suggestedDownloadName)
import Main.Config (backendUrl)
import Data.Maybe (fromMaybe, maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Prelude
import Unsafe.Coerce (unsafeCoerce)
import Fetch (Method(..), fetch)
import Endpoints.ResponseParser (validateResponse)
import Model.DownloadRequest (DownloadRequest)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.State.State (Source(..), WURL(..))
import Handlers.InputVideo.YoutubeUrlExtraction (extractYoutubeVideoId)
import Web.DOM.Document (createElement)
import Web.DOM.Element (toNode)
import Web.DOM.Node (appendChild, removeChild)
import Web.File.Url (createObjectURL, revokeObjectURL)
import Web.HTML (window)
import Web.HTML.HTMLAnchorElement as HA
import Web.HTML.HTMLDocument (body, toDocument)
import Web.HTML.HTMLElement (click, toElement) as HE
import Web.HTML.HTMLHyperlinkElementUtils (setHref)
import Web.HTML.Window (document)
import Web.File.Blob (Blob)
import Yoga.JSON (writeJSON)

downloadEndpoint :: String
downloadEndpoint = backendUrl <> "download"

callDownload :: Source -> Aff Unit
callDownload (WebURL (WURL u)) = do
  let request = ({ source: (WebURL (WURL u)) } :: DownloadRequest)
      maybeVideoId = extractYoutubeVideoId u
  response <- fetch downloadEndpoint
    { method: POST
    , body: writeJSON request
    , headers: { "Content-Type": "application/json" }
    }
  _ <- liftEffect $ validateResponse response
  blob <- response.blob
  liftEffect $ triggerDownloadFromBlob (fromMaybe "temp.txt" maybeVideoId) blob
callDownload (LocalFile _) = do
  liftEffect $ throwMinsiError (InvalidInput "downloadFull" "Download Full supports URL sources only. Use Download All for local file results.")

triggerDownloadFromBlob :: String -> Blob -> Effect Unit
triggerDownloadFromBlob filename blob = do
  blobUrl <- createObjectURL blob
  w <- window
  htmlDoc <- document w
  doc <- pure (toDocument htmlDoc)
  el <- createElement (unsafeCoerce "a") doc
  maybe (revokeObjectURL blobUrl) (go htmlDoc blobUrl) (HA.fromElement el)
  where
  go doc' blobUrl' anchor = do
    setHref blobUrl' (HA.toHTMLHyperlinkElementUtils anchor)
    HA.setDownload filename anchor
    mBody <- body doc'
    maybe (pure unit) (appendAndClick blobUrl' anchor) mBody

  appendAndClick blobUrl'' anchor b = do
    let anchorNode = HA.toNode anchor
    let bodyNode = toNode (HE.toElement b)
    appendChild anchorNode bodyNode
    HE.click (HA.toHTMLElement anchor)
    removeChild anchorNode bodyNode
    revokeObjectURL blobUrl''

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
