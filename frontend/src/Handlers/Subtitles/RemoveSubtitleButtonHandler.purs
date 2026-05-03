module Handlers.Subtitles.RemoveSubtitleButtonHandler where

import Prelude
import Components.HTMLTableElement (getRows)
import Data.Array (head)
import Control.Monad.Loops (iterateUntilM)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Maybe.Trans (MaybeT(..), runMaybeT)
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Effect (Effect)
import Effect.Console (log)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_subtitleTable)
import Data.Lens (view)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Web.DOM.DOMTokenList (contains)
import Web.DOM.Element (classList, fromNode, tagName, toEventTarget, toNode)
import Web.DOM.Internal.Types (Node)
import Web.DOM.Node (parentNode, removeChild)
import Web.Event.Event (target)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLButtonElement as HB
import Web.HTML.HTMLTableElement as HT
import Web.HTML.HTMLTableRowElement as HR

setRemoveSubtitleButtonHandler :: Effect Unit
setRemoveSubtitleButtonHandler = genericErrorsHandler $ do
  components <- loadComponents
  let subtitleTable = view _subtitleTable components
  log "Setting up remove subtitle button handlers"
  evl <- eventListener removeSubtitleButtonEventListener
  rows <- getRows subtitleTable
  traverse_ (\r -> addEventListener E.click evl false (tableRowEventTarget r)) rows
  log "Remove subtitle button handler set up successfully"
  where
  tableRowEventTarget r = toEventTarget (HR.toElement r)

addRemoveSubtitleListenerToRow :: HR.HTMLTableRowElement -> Effect Unit
addRemoveSubtitleListenerToRow row = do
  evl <- eventListener removeSubtitleButtonEventListener
  addEventListener E.click evl false (toEventTarget (HR.toElement row))

removeSubtitleButtonEventListener :: Event -> Effect Unit
removeSubtitleButtonEventListener ev = genericErrorsHandler $
  runMaybeT (removeSubtitleButtonEventListenerTrans ev)
    *> pure unit

removeSubtitleButtonEventListenerTrans :: Event -> MaybeT Effect Unit
removeSubtitleButtonEventListenerTrans ev = do
  lift $ log "Remove subtitle button clicked"
  buttonTarget <- MaybeT $ pure $ target ev >>= HB.fromEventTarget
  hasRemoveClass <- lift $ classList (HB.toElement buttonTarget) >>= flip contains "removeSubtitleButton"
  when (not hasRemoveClass) (MaybeT $ pure Nothing)
  let buttonNode = toNode (HB.toElement buttonTarget)
  tableRow <- findTrAncestor buttonNode
  removeRowFromDom tableRow

isTrElement :: Node -> Boolean
isTrElement node =
  fromMaybe false
    $ (_ == "TR") <<< tagName
        <$> fromNode node

getParentNode :: Node -> MaybeT Effect Node
getParentNode node = MaybeT $ parentNode node

findTrAncestor :: Node -> MaybeT Effect HR.HTMLTableRowElement
findTrAncestor node = do
  trNode <- iterateUntilM isTrElement getParentNode node
  MaybeT $ pure $ fromNode trNode >>= HR.fromElement

removeRowFromDom :: HR.HTMLTableRowElement -> MaybeT Effect Unit
removeRowFromDom tableRow = do
  let rowNode = HR.toNode tableRow
  parentNode' <- MaybeT $ parentNode rowNode
  lift $ removeChild rowNode parentNode'

-- | Remove the first (top) row of the subtitle table. Reuses removeRowFromDom.
-- | No-op if the table has no rows.
removeFirstSubtitleRow :: HT.HTMLTableElement -> Effect Unit
removeFirstSubtitleRow subtitleTable = do
  rows <- getRows subtitleTable
  maybe (pure unit) (\row -> runMaybeT (removeRowFromDom row) *> pure unit) (head rows)
