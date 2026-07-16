import fs from "node:fs";
import path from "node:path";
import { JSDOM } from "jsdom";

export const loadIndexHtmlIntoDom = function () {
  const candidates = [
    path.resolve(process.cwd(), "../public/index.html"),
    path.resolve(process.cwd(), "public/index.html"),
  ];
  const htmlPath = candidates.find((p) => fs.existsSync(p));
  if (htmlPath == null) {
    throw new Error(
      "Could not find public/index.html (tried: " + candidates.join(", ") + ")"
    );
  }
  const html = fs.readFileSync(htmlPath, "utf8");
  const dom = new JSDOM(html);
  globalThis.window = dom.window;
  globalThis.document = dom.window.document;
};
