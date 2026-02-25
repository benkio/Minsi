module Handlers.TextInputValidationHandler where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.HtmlIds (artistId, outputFilenameId, titleId)
import Data.Maybe (maybe)
import Data.Newtype (unwrap)
import Data.Validation.Semigroup (validation)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Model.ArtistPrefix (prefixForArtist)
import Model.ValidationErrors (toMap)
import Validations.NonEmptyValidation (nonEmptyValidation)
import Validations.OutputFilenameValidation (outputFilenameValidation)
import Web.DOM.Element (toEventTarget)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E
import Web.HTML.HTMLInputElement (value)
import Web.HTML.HTMLInputElement as HI

data TextInputValidationTargets = TIVT
  { outputFilename :: HI.HTMLInputElement
  , artist :: HI.HTMLInputElement
  , title :: HI.HTMLInputElement
  }

setTextInputValidationHandlers :: TextInputValidationTargets -> Effect Unit
setTextInputValidationHandlers (TIVT { outputFilename, artist, title }) = do
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
    outputFilename = (unwrap components.htmlInputs).filename
    uploadLocalFile = (unwrap components.htmlInputs).uploadLocalFile
  v <- value outputFilename
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> HI.setChecked true uploadLocalFile)
    (outputFilenameValidation outputFilenameId v)

-- | On artist change: if artist matches a known value, set output filename to that prefix; then validate non-empty.
artistChangeListener :: Event -> Effect Unit
artistChangeListener _ = genericErrorsHandler $ do
  components <- loadComponents
  let
    outputFilename = (unwrap components.htmlInputs).filename
    artist = (unwrap components.htmlInputs).artist
  v <- value artist
  maybe (pure unit) (\prefix -> HI.setValue prefix outputFilename) (prefixForArtist v)
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> pure unit)
    (nonEmptyValidation artistId v)

titleChangeListener :: Event -> Effect Unit
titleChangeListener _ = genericErrorsHandler $ do
  components <- loadComponents
  let title = (unwrap components.htmlInputs).title
  v <- value title
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> pure unit)
    (nonEmptyValidation titleId v)
