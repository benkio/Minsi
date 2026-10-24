module Validations.Number where

import Data.Number (nan)
import Effect (Effect)
import Main.MinsiErrors (MinsiError(..), throwMinsiError)
import Prelude
import Web.HTML.HTMLInputElement as HIE

valueAsNumber :: String -> HIE.HTMLInputElement -> Effect Number
valueAsNumber label el =
  HIE.valueAsNumber el >>=
    ( \numOrNan ->
        if numOrNan == nan then throwMinsiError (InvalidInput label "[Number] Conversion to Number failed with NaN")
        else pure numOrNan
    )
