module MinsiError where

import Effect.Exception (error, throwException)
import Effect (Effect)
import Prelude

data MinsiError
    = DependencyError String
    | YtdlpError String
    | FfmpegVideoError String
    | FfmpegMp3Error String
    | FfmpegGifError String
    | Id3v2Error String

instance Show MinsiError where
    show (YtdlpError s) = "🚫 Ytdlp error: " <> s
    show (FfmpegVideoError s) = "🚫 Ffmpeg video error: " <> s
    show (FfmpegMp3Error s) =  "🚫 Ffmpeg mp3 error: " <> s
    show (FfmpegGifError s) = "🚫 Ffmpeg gif error: " <> s
    show (Id3v2Error s) = "🚫 Id3v2 error: " <> s
    show (DependencyError s) = "🚫 Error while checking dependencies: " <> s

throwMinsiError :: forall a. MinsiError -> Effect a
throwMinsiError =
  throwException <<< error <<< show
