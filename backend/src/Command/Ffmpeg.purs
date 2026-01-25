module Ffmpeg where

import Data.Time.Duration (Milliseconds)

import Prelude

import Effect (Effect)

{-
              "ffmpeg",
              "-hide_banner",
              "-loglevel",
              "warning",
              "-i",
              s"${ytDlpCommandOutputUrlOrPath.get}",
              "-ss",
              millisToString(inputVideo.from.toMillis, "."),
              "-to",
              millisToString(inputVideo.to.toMillis, "."),
              path(mp4)
-}
downloadVideo :: String -> Milliseconds -> Milliseconds -> Effect Unit
downloadVideo videoSource start end = pure unit

downloadMp3 :: Effect Unit
downloadMp3 = pure unit

makePlainGif :: Effect Unit
makePlainGif = pure unit
