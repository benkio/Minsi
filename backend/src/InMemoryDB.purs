module InMemoryDB where

import Prelude
import Effect (Effect)
import Effect.Ref as Ref
import Data.Map as Map
import Data.Maybe (Maybe)
import Model.ProcessStatus (ProcessStatus)

type Filename = String

type Store = Ref.Ref (Map.Map Filename ProcessStatus)

initStore :: Effect Store
initStore = Ref.new Map.empty

insert :: Filename -> ProcessStatus -> Store -> Effect Unit
insert file status store =
  Ref.modify_ (Map.insert file status) store

lookup :: Filename -> Store -> Effect (Maybe ProcessStatus)
lookup filename store =
  Map.lookup filename <$> Ref.read store
