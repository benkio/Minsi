module Handlers.AdvancedOptionsToggleHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_advancedOptionsToggle, _advancedOptionsToggleLabel, _collapseAdvancedOptions)
import Data.Lens (view)
import Effect (Effect)
import Effect.Timer (setTimeout)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.DOMTokenList as DOMTokenList
import Web.DOM.Element as Element
import Web.DOM.Element (toEventTarget)
import Web.DOM.Node (setTextContent)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLDivElement as HD
import Web.HTML.HTMLSpanElement as HSP

setAdvancedOptionsToggleHandler :: Effect Unit
setAdvancedOptionsToggleHandler = genericErrorsHandler do
  components <- loadComponents
  let
    advancedOptionsToggle = view _advancedOptionsToggle components
    advancedOptionsToggleLabel = view _advancedOptionsToggleLabel components
    collapseAdvancedOptions = view _collapseAdvancedOptions components

  updateAdvancedOptionsToggleLabel collapseAdvancedOptions advancedOptionsToggleLabel

  advancedOptionsToggleEvL <-
    eventListener (advancedOptionsToggleListener collapseAdvancedOptions advancedOptionsToggleLabel)
  addEventListener
    E.click
    advancedOptionsToggleEvL
    false
    (toEventTarget (HB.toElement advancedOptionsToggle))

advancedOptionsToggleListener :: HD.HTMLDivElement -> HSP.HTMLSpanElement -> Event -> Effect Unit
advancedOptionsToggleListener collapseAdvancedOptions advancedOptionsToggleLabel _ = do
  _ <- setTimeout 0 (updateAdvancedOptionsToggleLabel collapseAdvancedOptions advancedOptionsToggleLabel)
  pure unit

updateAdvancedOptionsToggleLabel :: HD.HTMLDivElement -> HSP.HTMLSpanElement -> Effect Unit
updateAdvancedOptionsToggleLabel collapseAdvancedOptions advancedOptionsToggleLabel = do
  classList <- Element.classList (HD.toElement collapseAdvancedOptions)
  isExpanded <- DOMTokenList.contains classList "show"
  let nextLabel = if isExpanded then "Hide advanced options" else "Show advanced options"
  setTextContent nextLabel (HSP.toNode advancedOptionsToggleLabel)
