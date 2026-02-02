module Handlers.TextInputValidationHandler where

import Components.HtmlIds (artistId, outputFilenameId, titleId)
import Data.Validation.Semigroup (validation)
import Effect (Effect)
import Handlers.ErrorHandlers (genericErrorsHandler)
import Main.MinsiError (MinsiError(..), throwMinsiError)
import Model.ValidationErrors (toMap)
import Prelude
import Validations.NonEmptyValidation (nonEmptyValidation)
import Web.DOM.Element (toEventTarget)
import Web.HTML.HTMLInputElement (value)
import Web.HTML.HTMLInputElement as HI
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.Event.Internal.Types (Event)
import Web.HTML.Event.EventTypes as E

data TextInputValidationTargets = TIVT
  { outputFilename :: HI.HTMLInputElement
  , artist :: HI.HTMLInputElement
  , title :: HI.HTMLInputElement
  }

setTextInputValidationHandlers :: TextInputValidationTargets -> Effect Unit
setTextInputValidationHandlers (TIVT { outputFilename, artist, title }) = do
  outputFilenameEvL <- eventListener (nonEmptyChangeListener outputFilename outputFilenameId)
  artistEvL <- eventListener (nonEmptyChangeListener artist artistId)
  titleEvL <- eventListener (nonEmptyChangeListener title titleId)
  addEventListener E.change outputFilenameEvL false (toEventTarget (HI.toElement outputFilename))
  addEventListener E.change artistEvL false (toEventTarget (HI.toElement artist))
  addEventListener E.change titleEvL false (toEventTarget (HI.toElement title))
  pure unit

nonEmptyChangeListener :: HI.HTMLInputElement -> String -> Event -> Effect Unit
nonEmptyChangeListener input id _ = genericErrorsHandler $ do
  v <- value input
  validation
    (\errs -> throwMinsiError (InvalidInputs (toMap errs)))
    (\_ -> pure unit)
    (nonEmptyValidation id v)
