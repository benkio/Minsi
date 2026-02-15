module Handlers.InputVideo.InputSourceHandler where

import Effect (Effect)
import Prelude
import Web.HTML.HTMLInputElement as HI
import Web.HTML.HTMLSelectElement as HS

setInputsourcehandler :: HS.HTMLSelectElement -> HI.HTMLInputElement -> HI.HTMLInputElement -> Effect Unit
setInputsourcehandler _inputSource _youtubeUrl _localFile = pure unit -- TODO: implement
