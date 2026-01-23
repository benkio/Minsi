module Components.Modal where

import Effect (Effect)
import Prelude

foreign import showLoadingModal :: String -> Effect Unit
foreign import hideLoadingModal :: String -> Effect Unit
