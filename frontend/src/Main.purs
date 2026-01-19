module Main where

import Prelude

import Components.HtmlComponents (loadComponents)
import Components.Window (getDocument, raiseErrorAlert)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Console (log)
import Effect.Exception (Error, message)
import Main.CheckDependencies (checkDependecies)
import Control.Monad.Error.Class (catchError)
import Data.Either (Either(..))

main :: Effect Unit
main = genericErrorsHandler program

program :: Effect Unit
program = do
  runAff_ genericErrorsHandlerEither checkDependecies
  doc <- getDocument
  _ <- loadComponents doc
  log "Components correctly loaded"

genericErrorsHandler :: Effect Unit -> Effect Unit
genericErrorsHandler p = catchError p \e -> raiseErrorAlert (message e)

genericErrorsHandlerEither :: forall a. Either Error a -> Effect Unit
genericErrorsHandlerEither (Right _) = pure unit
genericErrorsHandlerEither (Left e) = raiseErrorAlert (message e)

-- TODOs --------------------------------
{-

- Add the Apply button handler that takes the htmlinputs, convert
  them to state and send them to the compute endpoint if the
  conversion is successful. disable the button until the call ends. animate the message section
- add yt handler + FFI iframe API + enable the rest of the control
- add slider cut logic UI constraint: cstartmax<cendmin, cendmax < yt video length, cstart < cend values
-- add subtitle logic UI constraint: 0-max length of yt cut and more...
-}
