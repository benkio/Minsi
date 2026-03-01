module Main where

import Prelude

import Components.HtmlComponents (loadComponents)
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
  runAff_ genericErrorsHandlerEither do
    htmlComponents <- liftEffect loadComponents
    liftEffect $ log "Components correctly loaded"
    updateAvailable <- checkUpdates
    if updateAvailable then
      liftEffect $ log "Update available! Exit"
    else do
      checkDependecies
      liftEffect $ setupEventHandlers htmlComponents
      liftEffect $ log "Setup Handlers Done"
