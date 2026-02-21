module InMemoryDB where

import Prelude

import Data.Map as Map
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Ref as Ref
import Model.ProcessStatus (ProcessStatus)
import Model.State (State)

type Filename = String
type StateProcessStatus = { state :: State, processStatus :: ProcessStatus }

type Store = Ref.Ref (Map.Map Filename StateProcessStatus)

initStore :: Effect Store
initStore = Ref.new Map.empty

insert :: Filename -> State -> ProcessStatus -> Store -> Effect Unit
insert file state processStatus store =
  Ref.modify_ (Map.insert file { state, processStatus }) store

lookup :: Filename -> Store -> Effect (Maybe StateProcessStatus)
lookup filename store =
  Map.lookup filename <$> Ref.read store
