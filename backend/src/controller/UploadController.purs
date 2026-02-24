module Controller.UploadController where

import InMemoryDB (Store)
import Node.Express.Handler (Handler)
import Node.Express.Response (end, setStatus)
import Prelude

uploadController :: Store -> Handler
uploadController _store = setStatus 404 *> end -- TODO: implement
