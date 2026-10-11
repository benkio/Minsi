module Command.Ffmpeg.Loop where

import Prelude

import Command.Command (runCommand)
import Command.Ffmpeg.Base (baseFlagsInput, baseFlagsOutput)
import Constants (mp4, reversed, reversedFull, tempVideo, txt)
import Data.Foldable (intercalate)
import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds)
import Effect (Effect)
import Effect.Aff (Aff, finally)
import Effect.Class (liftEffect)
import Effect.Console (log)
import MinsiErrors (MinsiError(..))
import Node.Buffer (fromString)
import Node.Encoding (Encoding(..))
import Node.FS.Sync as FSSync
import Node.Library.Execa (ExecaResult)
import Node.Path (FilePath)

loopTimeout :: Maybe Milliseconds
loopTimeout = Nothing

applyReverseLoop :: FilePath -> Aff ExecaResult
applyReverseLoop filename = do
  finally (loopCleanup filename) do
    _ <- makeReverseVideo filename
    makeConcatVideo filename

makeReverseVideo :: FilePath -> Aff ExecaResult
makeReverseVideo filename = do
  args <- liftEffect $ reverseLoopReverseArgs <$> mp4 filename <*> reversed filename
  process <- runCommand loopTimeout args FfmpegVideoError "ffmpeg"
  process.getResult

reverseLoopReverseArgs :: FilePath -> FilePath -> Array String
reverseLoopReverseArgs input output =
  baseFlagsInput
    <>
      [ "-i"
      , input
      , "-vf"
      , "reverse"
      , "-af"
      , "areverse"
      ]
    <> codecFlags
    <> baseFlagsOutput
    <> [ output ]
  where
  codecFlags =
    [ "-c:v"
    , "libx264"
    , "-c:a"
    , "aac"
    ]

makeConcatVideo :: FilePath -> Aff ExecaResult
makeConcatVideo filename = do
  args <- liftEffect $ prepareConcatArgs filename
  process <- runCommand loopTimeout args FfmpegVideoError "ffmpeg"
  process.getResult

prepareConcatArgs :: FilePath -> Effect (Array String)
prepareConcatArgs filename = do
  filepathMp4 <- mp4 filename
  filepathReversed <- reversed filename
  filepathTxt <- txt filename
  filepathReversedFull <- reversedFull filename
  writeConcatTxt filepathTxt [ filepathMp4, filepathReversed ]
  pure $ reverseLoopConcatArgs filepathTxt filepathReversedFull

reverseLoopConcatArgs :: FilePath -> FilePath -> Array String
reverseLoopConcatArgs filepathTxt output =
  baseFlagsInput
    <>
      [ "-f"
      , "concat"
      , "-safe"
      , "0"
      , "-i"
      , filepathTxt
      , "-c"
      , "copy"
      ]
    <> baseFlagsOutput
    <> [ output ]

writeConcatTxt :: FilePath -> Array FilePath -> Effect Unit
writeConcatTxt filepathTxt files = do
  bufferContent <- fromString txtContent UTF8
  log $ "[Loop] write concat txt: " <> filepathTxt <> " content=" <> txtContent
  FSSync.writeFile filepathTxt bufferContent
  where
  txtContent =
    intercalate "\n"
      (files <#> \f -> "file '" <> f <> "'")

loopCleanup :: String -> Aff Unit
loopCleanup filename = liftEffect do
  filepathMp4 <- mp4 filename
  filepathTempVideo <- tempVideo filename
  filepathReversed <- reversed filename
  filepathTxt <- txt filename
  filepathReversedFull <- reversedFull filename
  mp4Exists <- FSSync.exists filepathMp4
  when mp4Exists do
    log $ "[Loop] delete source video: " <> show filepathMp4
    FSSync.rm filepathMp4
  tempExists <- FSSync.exists filepathTempVideo
  when tempExists do
    log $ "[Loop] delete temp video: " <> show filepathTempVideo
    FSSync.rm filepathTempVideo
  reversedExists <- FSSync.exists filepathReversed
  when reversedExists do
    log $ "[Loop] delete reversed video: " <> show filepathReversed
    FSSync.rm filepathReversed
  txtExists <- FSSync.exists filepathTxt
  when txtExists do
    log $ "[Loop] delete concat txt: " <> show filepathTxt
    FSSync.rm filepathTxt
  reversedFullExists <- FSSync.exists filepathReversedFull
  when reversedFullExists do
    log $ "[Loop] rename " <> show filepathReversedFull <> " into " <> show filepathMp4
    FSSync.rename filepathReversedFull filepathMp4
