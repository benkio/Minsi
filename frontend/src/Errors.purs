module Errors where

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Show (class Show)

data Error =
  HTMLElementNotFound String

derive instance genericError :: Generic Error _

instance showError :: Show Error where
  show = genericShow
