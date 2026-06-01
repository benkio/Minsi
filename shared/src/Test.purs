module Shared.Test where

import Prelude

import Effect (Effect)
import Effect.Console (log)

test :: Effect Unit
test = log "Print from shared lib"
