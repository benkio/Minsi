module Handlers.Subtitles.SubtitleRangeValidationHandler where

import Prelude

import Components.HTMLTableElement (getRows)
import Components.HTMLTableRowElement (getEndInput, getStartInput)
import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_subtitleTable)
import Components.HtmlIdAndClasses (subtitleTableId)
import Data.Lens (view)
import Data.TraversableWithIndex (traverseWithIndex)
import Data.Validation.Semigroup (validation)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ValidationErrors (toMap)
import Validations.DurationRangeValidation (durationRangeValidation)
import Validations.Number (valueAsNumber)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLTableElement as HT

setSubtitleRangeValidationHandler :: Effect Unit
setSubtitleRangeValidationHandler = genericErrorsHandler do
  components <- loadComponents
  let subtitleTable = view _subtitleTable components
  evl <- eventListener (subtitleRangeValidationListener subtitleTable)
  addEventListener E.input evl false (toEventTarget (HT.toElement subtitleTable))
  addEventListener E.change evl false (toEventTarget (HT.toElement subtitleTable))

subtitleRangeValidationListener :: HT.HTMLTableElement -> Event -> Effect Unit
subtitleRangeValidationListener subtitleTable _ = genericErrorsHandler do
  rows <- getRows subtitleTable
  void $ traverseWithIndex validateRow rows
  where
  validateRow index row = do
    startInput <- getStartInput row
    endInput <- getEndInput row
    start <- valueAsNumber subtitleTableId startInput
    end <- valueAsNumber subtitleTableId endInput
    validation
      (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
      (const (pure unit))
      (durationRangeValidation ("[Subtitle row " <> show index <> "]") start end)
