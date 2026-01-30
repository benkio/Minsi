module Components.Modal where

import Effect (Effect)
import Prelude

foreign import showModal :: String -> Effect Unit
foreign import hideModal :: String -> Effect Unit
