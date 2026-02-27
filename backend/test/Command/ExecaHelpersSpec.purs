module Test.Command.ExecaHelpersSpec where

import Prelude

import Command.ExecaHelpers (execaResultToEither, isSuccessExit)
import Data.Either (isLeft, isRight)
import Data.Maybe (Maybe(..))
import Node.ChildProcess.Types (Exit(..), stringSignal)
import Node.Library.Execa (ExecaResult)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

mkResult :: Exit -> String -> String -> ExecaResult
mkResult exit cmd stderr =
  { originalMessage: Nothing
  , message: ""
  , shortMessage: ""
  , escapedCommand: cmd
  , exit
  , exitCode: Nothing
  , pid: Nothing
  , signal: Nothing
  , signalDescription: Nothing
  , stdout: ""
  , stderr
  , stdinError: Nothing
  , stdoutError: Nothing
  , stderrError: Nothing
  , timedOut: false
  , canceled: false
  , killed: false
  }

spec :: Spec Unit
spec = do
  describe "isSuccessExit" do
    it "returns true for Normally 0" $
      isSuccessExit (Normally 0) `shouldEqual` true

    it "returns false for Normally non-zero" $
      isSuccessExit (Normally 1) `shouldEqual` false

    it "returns false for BySignal" $
      isSuccessExit (BySignal (stringSignal "SIGTERM")) `shouldEqual` false

  describe "execaResultToEither" do
    it "returns Right for successful exit" $
      isRight (execaResultToEither "test" (mkResult (Normally 0) "cmd" "")) `shouldEqual` true

    it "returns Left for failed exit with stderr and command info" do
      let result = execaResultToEither "download" (mkResult (Normally 1) "ffmpeg -i foo" "file not found")
      isLeft result `shouldEqual` true

    it "returns Left for signal exit" $
      isLeft (execaResultToEither "test" (mkResult (BySignal (stringSignal "SIGKILL")) "cmd" "killed")) `shouldEqual` true
