module Components.LoadingModal
  ( loadingModalExtraContentValues
  , loadingModalExtraContentRotation
  ) where

import Components.HtmlComponents (loadComponents)
import Components.HtmlComponents.Lenses (_loadingModalExtraContent)
import Data.Array (length, (!!))
import Data.Lens (view)
import Data.Maybe (fromMaybe)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Prelude
import Web.DOM.Node as Node
import Web.HTML.HTMLSpanElement as HSP

loadingModalExtraContentRotation :: Int -> Aff Unit
loadingModalExtraContentRotation idx = do
  components <- liftEffect loadComponents
  let
    span = view _loadingModalExtraContent components
    extraContent = fromMaybe "" (loadingModalExtraContentValues !! (idx `mod` length loadingModalExtraContentValues))
  liftEffect $ Node.setTextContent extraContent (HSP.toNode span)

loadingModalExtraContentValues :: Array String
loadingModalExtraContentValues =
  [ "09/1939 Poland invaded"
  , "09/1939 Warsaw bombarded"
  , "05/1940 France invaded"
  , "05/1940 The Battle of Dunkirk"
  , "07/1940 Britain bombed"
  , "09/1940 London Blitz starts"
  , "06/1941 USSR invaded"
  , "12/1941 Pearl Harbor bombed"
  , "06/1942 Midway naval battle"
  , "08/1942 Guadalcanal battle"
  , "07/1942 Stalingrad battle starts"
  , "11/1942 Torch landings begin"
  , "02/1943 Stalingrad battle ends"
  , "07/1943 Sicily invaded"
  , "06/1944 Normandy landings"
  , "08/1944 Paris liberated"
  , "12/1944 Ardennes offensive"
  , "02/1945 Dresden bombed"
  , "04/1945 Berlin assaulted"
  , "04/1945 Hitler dies"
  , "05/1945 Germany surrenders"
  , "08/1945 Hiroshima/Nagasaki bombed"
  ]
