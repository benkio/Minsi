module Command.Ffmpeg.Base where

import Config (currentVersion)
import Prelude

baseFlagsInput :: Array String
baseFlagsInput = [ "-hide_banner", "-loglevel", "warning" ]

baseFlagsOutput :: Array String
baseFlagsOutput = [ "-metadata", "encoding_tool=Minsi-" <> currentVersion ]
