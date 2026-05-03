module Handlers.TextInputValidationHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_artist, _filename, _title, _uploadLocalFile)
import Components.HtmlIdAndClasses (artistId, outputFilenameId, titleId)
import Data.Lens (view)
import Data.Maybe (maybe)
import Data.Validation.Semigroup (andThen, validation)
import Effect (Effect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ArtistPrefix (prefixForArtist)
import Model.ValidationErrors (toMap)
import Validations.NonEmptyValidation (nonEmptyValidation)
import Validations.OutputFilenameValidation (outputFilenameValidation)
import Validations.PrintableAsciiLatinValidation (printableAsciiLatinValidation)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLInputElement (value)
import Web.HTML.HTMLInputElement as HI

setTextInputValidationHandlers :: Effect Unit
setTextInputValidationHandlers = do
  components <- loadComponents
  let
    outputFilename = view _filename components
    artist = view _artist components
    title = view _title components
  outputFilenameEvL <- eventListener outputFilenameChangeListener
  artistEvL <- eventListener artistChangeListener
  titleEvL <- eventListener titleChangeListener
  addEventListener E.change outputFilenameEvL false (toEventTarget (HI.toElement outputFilename))
  addEventListener E.change artistEvL false (toEventTarget (HI.toElement artist))
  addEventListener E.change titleEvL false (toEventTarget (HI.toElement title))
  pure unit

-- | On output filename change: validate letters, numbers and underscores only (no spaces).
outputFilenameChangeListener :: Event -> Effect Unit
outputFilenameChangeListener _ = genericErrorsHandler $ do
  components <- loadComponents
  let
    outputFilename = view _filename components
    uploadLocalFile = view _uploadLocalFile components
  v <- value outputFilename
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> log "[TextInputValidationHandler] set the uploadLocalFile to true" *> HI.setChecked true uploadLocalFile)
    (outputFilenameValidation outputFilenameId v)

-- | On artist change: if artist matches a known value, set output filename to that prefix; then validate non-empty.
artistChangeListener :: Event -> Effect Unit
artistChangeListener _ = genericErrorsHandler $ do
  components <- loadComponents
  let
    outputFilename = view _filename components
    artist = view _artist components
  v <- value artist
  maybe (pure unit) (\prefix -> HI.setValue prefix outputFilename) (prefixForArtist v)
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> pure unit)
    (nonEmptyValidation artistId v `andThen` (printableAsciiLatinValidation artistId))

titleChangeListener :: Event -> Effect Unit
titleChangeListener _ = genericErrorsHandler $ do
  components <- loadComponents
  let title = view _title components
  v <- value title
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> pure unit)
    (nonEmptyValidation titleId v `andThen` (printableAsciiLatinValidation titleId))
