export const _getReqBody = (req) => req.body;

export const _stringify = (a) => {
  try {
    if (a === undefined) return "undefined";
    if (a === null) return "null";
    if (typeof a === "string") return a;
    return JSON.stringify(a);
  } catch (e) {
    try {
      return String(a);
    } catch (_) {
      return "[unstringifiable]";
    }
  }
};

export const _parseJson = (s) => JSON.parse(s);

