module Main where

import Prelude

import Components.HtmlComponents (loadComponents)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Console (log)
import Handlers.ErrorHandlers (genericErrorsHandler, genericErrorsHandlerEither)
import Handlers.Handlers (setupEventHandlers)
import Main.CheckDependencies (checkDependecies)

main :: Effect Unit
main = genericErrorsHandler program

program :: Effect Unit
program = do
  runAff_ genericErrorsHandlerEither checkDependecies
  htmlComponents <- loadComponents
  log "Components correctly loaded"
  setupEventHandlers htmlComponents
  log "Setup Handlers Done"
