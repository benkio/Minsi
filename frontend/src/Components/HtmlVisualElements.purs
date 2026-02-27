module Components.HtmlVisualElements where

import Prelude

import Components.HTMLDivElement (addClass, removeClass)
import Components.HtmlComponents (HtmlVisualElements(..))
import Effect (Effect)

showHiddenElements :: HtmlVisualElements -> Boolean -> Effect Unit
showHiddenElements (HtmlVisualElements { videoSourceRow, videoRow, subtitlesRow, playbackPositionResultRow }) reverseLoop = do
  removeClass "d-none" videoSourceRow
  removeClass "d-none" videoRow
  if reverseLoop then addClass "d-none" subtitlesRow else removeClass "d-none" subtitlesRow
  removeClass "d-none" playbackPositionResultRow
