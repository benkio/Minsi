module Main.CheckDependencies where

import Prelude
import Data.Unit (Unit)
import Effect.Aff (Aff)
import Main.Config (backendUrl)
import Fetch (fetch, Method(..))
import Fetch.Yoga.Json (fromJSON)
import Control.Monad.Error.Class (throwError)
import Main.MinsiErrors (MinsiError(..))
import Foreign (Foreign)

type MissingDependenciesResponse = { json :: { missedDependencies :: Array String } }

checkDependeciesEndpoint :: String
checkDependeciesEndpoint = backendUrl <> "/checkDependencies"

checkDependecies :: Aff Unit
checkDependecies = do
  { status, text } <- fetch checkDependeciesEndpoint { method: POST}
  if status == 200
  then pure unit
  else missingDependencies text

missingDependencies :: Aff Foreign -> Aff Unit
missingDependencies jsonText = do
  { json: { missedDependencies: deps } } :: MissingDependenciesResponse <- fromJSON jsonText
  throwError $ MissingDependenciesError deps
