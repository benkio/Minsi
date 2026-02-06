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
   spago bundle -p minsi-frontend --platform browser --source-maps --minify --outfile=../public/index.js
   ```

3. **Use the app**
   - Open **http://localhost:8080** in your browser.
   - See **[Instructions](http://localhost:8080/instructions.html)** for how to get video, MP3, and GIF from a YouTube URL.

Output files are written to **`public/output/`** (e.g. `filename.mp4`, `filename.mp3`, `filenameGif.mp4`).

## Running with Docker

The project includes a multi-stage **Dockerfile** that builds the frontend and backend and runs the app with only the required runtime dependencies (Node, ffmpeg, yt-dlp, id3v2, fonts).
The docker image is published on dockerhub: https://hub.docker.com/r/benkio/minsi
Pull the latest version with: `docker pull benkio/minsi:latest`

**Build the image** (from project root):

```bash
docker build -t minsi:latest .
```

**Run the container** (publish port 8080 so the app is reachable from your host):

```bash
docker run -d -p 8080:8080 minsi:latest
```

Then open **http://localhost:8080** in your browser.

- **Run in background:** The `-d` flag runs the container detached. Omit it to see server logs in the terminal.
- **Name the container:** Add `--name minsi-app` to make it easier to stop or inspect:
  `docker stop minsi-app` and `docker logs -f minsi-app`.
- **Host on a different port:** Use e.g. `-p 3000:8080` to access the app at http://localhost:3000.

The image is built for **linux/amd64**. On **ARM** (e.g. Apple Silicon) it runs via emulation. To avoid the platform warning, run with:
`docker run --platform linux/amd64 -d -p 8080:8080 minsi:latest`.

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
