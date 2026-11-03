module Components.HTMLTitle where

import Prelude

import Data.Array (findIndex, length, (!!))
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.String (stripPrefix)
import Data.String.Pattern (Pattern(..))
import Effect (Effect)
import Web.HTML.HTMLTitleElement (HTMLTitleElement, setText, text)

normalTitle :: String
normalTitle = "Minsi"

wipTitlePrefix :: Array String
wipTitlePrefix =
  [ "🐱"
  , "🐈"
  , "🙀"
  , "😿"
  , "😾"
  , "😽"
  , "😼"
  , "😻"
  , "😺"
  , "😹"
  , "😸"
  ]

setNormalTitle :: HTMLTitleElement -> Effect Unit
setNormalTitle = setText normalTitle

setWIPTitle :: HTMLTitleElement -> Effect Unit
setWIPTitle title = do
  currentTitle <- text title
  setText (calculateNextElement currentTitle <> " " <> normalTitle) title

calculateNextElement :: String -> String
calculateNextElement currentTitle =
  fromMaybe "" $ wipTitlePrefix !! nextIndex
  where
  nextIndex = case findIndex (\prefix -> isPrefix prefix currentTitle) wipTitlePrefix of
    Nothing -> 0
    Just currentIndex -> (currentIndex + 1) `mod` length wipTitlePrefix
  isPrefix prefix = isJust <<< stripPrefix (Pattern prefix)
