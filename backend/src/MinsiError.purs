module MinsiError where

import Effect.Exception (error, throwException)
import Effect (Effect)
import Prelude

data MinsiError
    = YtdlpError String
    | FfmpegVideoError String
    | FfmpegMp3Error String
    | FfmpegGifError String
    | Id3v2Error String

instance Show MinsiError where
    show (YtdlpError s) = ""
    show (FfmpegVideoError s) = ""
    show (FfmpegMp3Error s) = ""
    show (FfmpegGifError s) = ""
    show (Id3v2Error s) = ""

throwMinsiError :: forall a. MinsiError -> Effect a
throwMinsiError =
  throwException <<< error <<< show
