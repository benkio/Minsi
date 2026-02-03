import helmetPkg from "helmet";

export const helmet = helmetPkg({
  referrerPolicy: { policy: "strict-origin-when-cross-origin" },
  contentSecurityPolicy: {
    directives: {
      ...helmetPkg.contentSecurityPolicy.getDefaultDirectives(),
      "script-src": ["'self'", "https://cdn.jsdelivr.net", "https://www.youtube.com", "https://s.ytimg.com"],
      "style-src": ["'self'", "https://cdn.jsdelivr.net", "'unsafe-inline'"],
      "connect-src": ["'self'", "https://cdn.jsdelivr.net", "https://www.youtube.com", "https://s.ytimg.com", "https://i.ytimg.com"],
      "frame-src": ["'self'", "https://www.youtube.com"],
      "img-src": ["'self'", "data:", "https://i.ytimg.com"],
    },
  },
});
