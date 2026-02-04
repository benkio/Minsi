module Api.Request.Download where

import Prelude
import Constants (gif, mp3, mp4)
import Effect (Effect)
import Node.Path (FilePath)

data DownloadRequest
  = DownloadRequestGif String
  | DownloadRequestVideo String
  | DownloadRequestMp3 String

toFilePath :: DownloadRequest -> Effect FilePath
toFilePath (DownloadRequestGif fn) = gif fn
toFilePath (DownloadRequestVideo fn) = mp4 fn
toFilePath (DownloadRequestMp3 fn) = mp3 fn

instance Show DownloadRequest where
  show (DownloadRequestGif fn) = "(DownloadRequestGif " <> show fn <> ")"
  show (DownloadRequestVideo fn) = "(DownloadRequestVideo " <> show fn <> ")"
  show (DownloadRequestMp3 fn) = "(DownloadRequestMp3 " <> show fn <> ")"
