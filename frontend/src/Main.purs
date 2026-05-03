module Main where

import Prelude

import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Handlers.Handlers (setupEventHandlers)
import Main.CheckDependencies (checkDependecies)
import Main.CheckUpdates (checkUpdates)

main :: Effect Unit
main = genericErrorsHandler program

program :: Effect Unit
program = do
  runAff_ genericErrorsHandlerEither (checkUpdates *> checkDependecies)
  log "Setup Handlers 🏁"
  liftEffect setupEventHandlers
  log "Setup Handlers ✅"
