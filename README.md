# Minsi

**Opinionated YouTube Clip Video, GIF & Audio Extractor**

A web application to download YouTube videos and produce customized clips: **video** (MP4), **MP3** audio, and **GIF** (with optional subtitles), with best-possible quality.

## Project structure

- **[Frontend](./frontend/README.md)** — PureScript UI (Bootstrap, YouTube embed)
- **[Backend](./backend/README.md)** — PureScript Express server (yt-dlp, ffmpeg, id3v2)

## System dependencies

Required for video/audio processing (must be on your `PATH`):

| Tool     | Purpose                    |
|----------|----------------------------|
| **ffmpeg** | Video/audio conversion     |
| **yt-dlp** | YouTube download           |
| **id3v2**  | MP3 metadata (artist/title)|
| **fc-list** | Font listing (subtitles)   |

You also need **Impact** and **Arial Black** fonts installed if you use subtitles.

## Quick start

1. **Backend** (from project root):
   ```bash
   cd backend
   npm install
   spago build
   spago run
   ```
   Server runs at **http://localhost:8080**.

2. **Frontend** (in another terminal):
   ```bash
   cd frontend
   spago install
   spago build
   spago bundle-app -t ../public/index.js
   ```

3. **Use the app**
   - Open **http://localhost:8080** in your browser.
   - See **[Instructions](http://localhost:8080/instructions.html)** for how to get video, MP3, and GIF from a YouTube URL.

Output files are written to **`public/output/`** (e.g. `filename.mp4`, `filename.mp3`, `filenameGif.mp4`).

## Bundle for Node

From the project root you can run **`./bundle.sh`** to build the frontend, copy assets, build and bundle the backend, and patch the server for the dist layout. Then run `node dist/server.js` (from project root or from `dist/`).

Manual steps (if you prefer):

0. Be sure to be able to run the project from the `backend` and everything works.
1. Copy `public` and `node_modules` into the dist folder:
   ```bash
   cp -r public/ dist/public/
   cp -r backend/node_modules/ dist/node_modules/
   ```
2. In `backend/src/Constants.purs`, change `publicDir` from `"../public"` to `"./public"`.
3. From the backend directory, run `spago build`.
4. Bundle the backend into a single JS file (using `backend/run.js` so the server actually starts—the compiled PureScript only exports `main`, it doesn’t call it):
   ```bash
   npx esbuild backend/run.js --bundle --platform=node --outfile=dist/server.js --packages=external
   ```
5. Test with `node dist/server.js` (from project root or from `dist/`).

## Motivation

I needed a single tool to turn a YouTube clip into:

- A **GIF** (with optional subtitles)
- An **MP3** audio extract
- A **video** clip

[This script](https://gist.github.com/benkio/103960b7b5a5781c222df1c4e31544a2) did the job; Minsi adds a **web UI** so it’s easier to use.
