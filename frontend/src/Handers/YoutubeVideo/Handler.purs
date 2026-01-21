module Handers.YoutubeVideo.Handler where

import Main.MinsiErrors (MinsiError(..), throwMinsiError)

import Validations.YoutubeValidation (youtubeUrlValidation)
import Data.Foldable (foldl)
import Data.Traversable (traverse)
import Data.Validation.Semigroup (invalid)

import Data.Maybe (Maybe, maybe)

import Prelude
import Effect (Effect)
import Web.DOM.Element (fromEventTarget)
import Web.Event.Internal.Types (Event)
import Web.HTML.HTMLInputElement as HI
import Web.Event.Event (target)
import Effect.Console (log)
import Handers.ErrorHandlers (genericErrorsHandler)

youtubeUrlEventListener :: Event -> Effect Unit
youtubeUrlEventListener ev = genericErrorsHandler $ do
  rawValue <- getInputValue ev
  let youtubeUrlV = maybe (invalid [ "Empty YoutubeUrl Input" ]) youtubeUrlValidation rawValue
  youtubeUrl <- foldl (\_ v -> pure v) (throwMinsiError (InvalidInput (show rawValue))) youtubeUrlV
  log ("Youtube Url Handler fired with value: " <> show youtubeUrl)

getInputValue :: Event -> Effect (Maybe String)
getInputValue ev =
  traverse (HI.value) (target ev >>= fromEventTarget >>= HI.fromElement)
