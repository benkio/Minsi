module Model.ValidationErrors where

import Data.Map (Map, singleton, union)
import Data.Newtype (class Newtype)
import Prelude

newtype ValidationErrors = ValidationErrors (Map String String)

derive instance Newtype ValidationErrors _

instance Semigroup ValidationErrors where
  append (ValidationErrors m1) (ValidationErrors m2) =
    ValidationErrors (union m1 m2)

toMap :: ValidationErrors -> Map String String
toMap (ValidationErrors m) = m

fromSingleton :: String -> String -> ValidationErrors
fromSingleton k v = ValidationErrors (singleton k v)
