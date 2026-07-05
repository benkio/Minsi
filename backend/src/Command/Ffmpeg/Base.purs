module Command.Ffmpeg.Base where

import Config (currentVersion)
import Prelude

baseFlags :: Array String
baseFlags = [ "-hide_banner", "-loglevel", "warning", "-metadata", "encoding_tool=Minsi " <> currentVersion ]
