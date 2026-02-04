module Handlers.TextInputValidationHandler where

import Components.HtmlIds (artistId, outputFilenameId, titleId)
import Data.Maybe (maybe)
import Data.Validation.Semigroup (validation)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.ArtistPrefix (prefixForArtist)
import Model.ValidationErrors (toMap)
import Prelude
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
  outputFilenameEvL <- eventListener (outputFilenameChangeListener outputFilename)
  artistEvL <- eventListener (artistChangeListener outputFilename artist)
  titleEvL <- eventListener (nonEmptyChangeListener title titleId)
  addEventListener E.change outputFilenameEvL false (toEventTarget (HI.toElement outputFilename))
  addEventListener E.change artistEvL false (toEventTarget (HI.toElement artist))
  addEventListener E.change titleEvL false (toEventTarget (HI.toElement title))
  pure unit

-- | On output filename change: validate letters, numbers and underscores only (no spaces).
outputFilenameChangeListener :: HI.HTMLInputElement -> Event -> Effect Unit
outputFilenameChangeListener input _ = genericErrorsHandler $ do
  v <- value input
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> pure unit)
    (outputFilenameValidation outputFilenameId v)

-- | On artist change: if artist matches a known value, set output filename to that prefix; then validate non-empty.
artistChangeListener :: HI.HTMLInputElement -> HI.HTMLInputElement -> Event -> Effect Unit
artistChangeListener outputFilename artist _ = genericErrorsHandler $ do
  v <- value artist
  maybe (pure unit) (\prefix -> HI.setValue prefix outputFilename) (prefixForArtist v)
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> pure unit)
    (nonEmptyValidation artistId v)

nonEmptyChangeListener :: HI.HTMLInputElement -> String -> Event -> Effect Unit
nonEmptyChangeListener input id _ = genericErrorsHandler $ do
  v <- value input
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> pure unit)
    (nonEmptyValidation id v)
