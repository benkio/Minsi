module Components.HTMLMediaElement where

import Effect (Effect)
import Prelude
import Web.HTML.HTMLMediaElement (HTMLMediaElement, load, pause, setSrc)

setMediaSrcAndLoad :: String -> HTMLMediaElement -> Effect Unit
setMediaSrcAndLoad url media = do
  pause media
  setSrc url media
  load media
