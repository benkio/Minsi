module InMemoryDB where

import Prelude
import Effect (Effect)
import Effect.Ref as Ref
import Data.Map as Map
import Data.Posix (Pid)
import Data.Maybe (Maybe)

type Filename = String

type Store = Ref.Ref (Map.Map Filename Pid)

initStore :: Effect Store
initStore = Ref.new Map.empty

insert :: Filename -> Pid -> Store -> Effect Unit
insert file pid store =
  Ref.modify_ (Map.insert file pid) store

lookup :: Filename -> Store -> Effect (Maybe Pid)
lookup filename store =
  Map.lookup filename <$> Ref.read store

