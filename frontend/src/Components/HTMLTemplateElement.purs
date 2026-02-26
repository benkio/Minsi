module Components.HTMLTemplateElement where

import Prelude

import Data.Maybe (maybe)
import Effect (Effect)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Web.DOM.DocumentFragment as DF
import Web.DOM.ParentNode (firstElementChild)
import Web.HTML.HTMLTableRowElement as HR
import Web.HTML.HTMLTemplateElement as HTP

getRow :: HTP.HTMLTemplateElement -> Effect HR.HTMLTableRowElement
getRow subtitleTemplateElement = do
  fragment <- HTP.content subtitleTemplateElement
  firstEl <- firstElementChild (DF.toParentNode fragment)
  maybe (throwMinsiError (HTMLElementNotFound "subtitleRowTemplate")) pure (firstEl >>= HR.fromElement)
