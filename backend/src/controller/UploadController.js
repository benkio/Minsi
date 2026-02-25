export const _getUploadedFileOriginalName = (req) => req.file.originalname ?? null;
export const _getUploadedFileBuffer = (req) => req.file.buffer ?? null;
