module Middleware.MulterUpload where

import Node.Express.Types (Middleware)

foreign import multerUploadMiddleware :: Middleware
