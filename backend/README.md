# Minsi Backend

PureScript Express server for the Minsi web app. It serves the frontend (from `public/`), runs the API used by the UI, and executes video/audio pipelines (yt-dlp, ffmpeg, id3v2).

## Dependencies

- **PureScript** + **Spago** — build and package management
- **Node.js** — runtime (Express)
- **npm**: `express` (and any transitive deps)

System tools used at runtime (must be on `PATH`): **ffmpeg**, **yt-dlp**, **id3v2**, **fc-list**.

## Setup

1. Install PureScript and Spago (if needed):
   ```bash
   npm install -g purescript spago
   ```

2. From the **backend** directory:
   ```bash
   npm install
   spago install
   ```

## Usage

### Development

1. **Build:**
   ```bash
   spago build
   ```

2. **Run the server:**
   ```bash
   spago run
   ```
   Listens on **http://localhost:8080**.

3. **Format:**
   ```bash
   npx purs-tidy format-in-place "src/**/*.purs" && npx purs-tidy format-in-place "test/**/*.purs"
   ```

### Behaviour

- Serves static files from **`../public/`** (relative to the backend directory).
- Root (`/`) serves **`index.html`**; other assets (e.g. `index.js`, `instructions.html`) are served by path.
- Exposes API routes used by the frontend (e.g. dependency check, compute, status).
- Writes output files (MP4, MP3, GIF) under **`public/output/`**.

### Configuration

- **Port:** 8080 (set in `Main.purs`).
- **Static root:** `../public/` (ensure the frontend is built and output is in `public/` before running).
