module Test.Main where

import Prelude

import Data.Maybe (maybe)
import Effect (Effect)
import Node.Process (lookupEnv)
import Test.Spec.Discovery (discoverAndRunSpecs)
import Test.Spec.Reporter.Console (consoleReporter)

main :: Effect Unit
main = discoverAndRunSpecs [ consoleReporter ] ".*Spec$"

isNotCI :: Effect Boolean
isNotCI = maybe true (const false) <$> lookupEnv "CI"
