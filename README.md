# Minsi

**Opinionated Video Clip, GIF & Audio Extractor**

A web application to download supported video URLs (YouTube and selected mirror hosts) and produce customized clips: **video** (MP4), **MP3** audio, and **GIF** (with optional subtitles), with best-possible quality.

**PROJECT IN MAINTENANCE MODE**
I don't plan to develop new features on this for now. Just fix bugs and keep it working

## Project structure

- **[Frontend](./frontend/README.md)** — PureScript UI (Bootstrap, YouTube embed)
- **[Backend](./backend/README.md)** — PureScript Express server (yt-dlp, ffmpeg, id3v2)
- **[Shared](./shared/)** — Contains shared types and logic between Frontend and Backend

## System dependencies

Required for video/audio processing (must be on your `PATH`):

| Tool     | Purpose                    |
|----------|----------------------------|
| **ffmpeg** | Video/audio conversion     |
| **yt-dlp** | Video download from supported hosts |
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
  - See **[Instructions](http://localhost:8080/instructions.html)** for how to get video, MP3, and GIF from a supported video URL.

Output files are written to **`public/output/`** (e.g. `rphjb_Hello.mp4`, `rphjb_Hello.mp3`, `rphjb_HelloGif.mp4`).
The output filename must follow the format `prefix_Name`: 1–5 lowercase letters, an underscore, then a capitalized name with letters and numbers.

## Running with Docker

The project includes a multi-stage **Dockerfile** that builds the frontend and backend and runs the app with only the required runtime dependencies (Node, ffmpeg, yt-dlp, id3v2, fonts).

The Docker image is published on Docker Hub: [benkio/minsi](https://hub.docker.com/r/benkio/minsi).

### From scratch (new machine with Docker installed)

#### 1. Pull the image

```bash
docker pull benkio/minsi:latest
```

#### 2a. Single Script - Port 8080 - With Cookies:

Recommended one-command startup (no clone required):

```bash
curl -fsSL https://raw.githubusercontent.com/benkio/minsi/main/start-minsi.sh -o start-minsi.sh
chmod +x ./start-minsi.sh
./start-minsi.sh
```

`start-minsi.sh` tries to export browser cookies from host profiles and then starts `docker run -d`. By default it tries `chrome`, `chromium`, `brave`, `firefox`, `edge`, `opera`, `vivaldi`, `safari`, writes `~/.config/minsi/cookies.txt`, and mounts that file to the container as read-only when available.

If you cloned the project, you can run the local script directly from repo root:

```bash
./start-minsi.sh
```

Useful options:

```bash
./start-minsi.sh --browser firefox --browser chrome --output "$HOME/.config/minsi/cookies.txt"
./start-minsi.sh --strict-cookies
./start-minsi.sh --no-pull
./start-minsi.sh --image benkio/minsi:latest --container minsi-app --port 8080
```

Notes:
- `cookies.txt` must be in Netscape format (the format yt-dlp expects).
- Keep the mount read-only (`:ro`) and avoid committing cookie files anywhere in this repository.
- Minsi now tries `YTDLP_COOKIES_FILE` first, then no cookies, then browser-cookie extraction fallbacks.
- The startup helper script is at [`./start-minsi.sh`](./start-minsi.sh).

#### 2b. Manual - Port 8080 - No Cookies:

```bash
docker run -d --name minsi-app -p 8080:8080 benkio/minsi:latest
```

#### 3. Open the App

Then open **http://localhost:8080** in your browser.

The image is built for **linux/amd64**. On **ARM** (e.g. Apple Silicon) it runs via emulation. To avoid the platform warning, run with:
`docker run --platform linux/amd64 -d --name minsi-app -p 8080:8080 benkio/minsi:latest`.

Useful commands:

- **See logs:** `docker logs -f minsi-app`
- **Stop:** `docker stop minsi-app`
- **Remove:** `docker rm minsi-app`
- **Run on a different port:** `docker run -d --name minsi-app -p 3000:8080 benkio/minsi:latest` → open `http://localhost:3000`

### Updating the image

When a newer `benkio/minsi:latest` is published, the app will show a blocking dialog at the top linking here.
The banner is dialog by a simple backend check comparing `backend/src/Config.purs` `currentVersion` with the latest GitHub tag from `https://api.github.com/repos/benkio/minsi/tags`.

Pull the new image:

```bash
docker pull benkio/minsi:latest
```

Recreate the container so it uses the new image:

```bash
docker stop minsi-app
docker rm minsi-app
docker run -d --name minsi-app -p 8080:8080 benkio/minsi:latest
```

### Build the image locally (optional)

From the project root:

```bash
docker build -t benkio/minsi:latest .
```

## Publish Docker Image

A GitHub Actions workflow (**Publish Docker Image**) can build and push the image to Docker Hub.
Trigger it manually from the Actions tab, specifying a tag (defaults to `latest`).
It requires `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` repository secrets.

To publish manually instead:

```bash
docker build -t benkio/minsi:latest .
docker push benkio/minsi:latest
```

## CI & Automation

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| **CI** (`ci.yml`) | Every push | Builds, formats, and tests both backend and frontend. Also builds and smoke-tests the Docker image. |
| **Publish Docker Image** (`publish.yml`) | Manual (`workflow_dispatch`) | Builds and pushes the Docker image to Docker Hub. |
| **Update Dependencies** (`update-dependencies.yml`) | Weekly (Monday 09:00 UTC) or manual | Updates npm and spago dependencies, opens a PR, and auto-merges if CI passes. |

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

I needed a single tool to turn a video clip into:

- A **GIF** (with optional subtitles)
- An **MP3** audio extract
- A **video** clip

[This script](https://gist.github.com/benkio/103960b7b5a5781c222df1c4e31544a2) did the job; Minsi adds a **web UI** so it’s easier to use.
