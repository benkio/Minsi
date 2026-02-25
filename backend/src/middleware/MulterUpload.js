import multer from "multer";

const upload = multer({ storage: multer.memoryStorage() });

export const multerUploadMiddleware = (req, res, next) => {
  upload.single("file")(req, res, (err) => {
    if (err) return next(err);
    next();
  });
};
